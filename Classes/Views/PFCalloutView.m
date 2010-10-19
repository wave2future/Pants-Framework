//
//  PFCalloutView.m
//  Disney Treasure Hunt
//
//  Created by Paul Alexander on 10/15/10.
//  Copyright (c) 2010 n/a. All rights reserved.
//

#import "PFCalloutView.h"
#import "PFCalloutLayer.h"
#import "PFCellContentView.h"
#import "PFDrawTools.h"
#import "CALayer+PFExtensions.h"
#import <QuartzCore/QuartzCore.h>


@implementation PFCalloutView

@synthesize  closeOnTap;

-(void) dealloc 
{
    SafeRelease( calloutLayer );
    SafeRelease( contentView );
    
    
    [super dealloc];
}

//+(Class) layerClass { return [PFCalloutLayer class]; }

-(id) initWithFrame: (CGRect) frame 
{
    if( self = [super initWithFrame: frame] ) 
    {
        //self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent: 0.5];
        
        calloutLayer = [[PFCalloutLayer alloc] init];
        [self.layer addSublayer: calloutLayer];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        [self addTarget: self action: @selector(tapped) forControlEvents: UIControlEventTouchUpInside];

        
        frame.origin = CGPointZero;
        frame = CGRectInset( frame, kPFCalloutContentInset, kPFCalloutContentInset );
        contentView = [[PFCellContentView alloc] initWithFrame: frame];
        [self addSubview: contentView];
    }
    return self;
}

#pragma mark -
#pragma mark State

-(BOOL) isOpaque { return NO; }
-(BOOL) clearsContextBeforeDrawing { return YES; }

-(UIView *) contentView { return contentView; }
-(void) setContentView: (UIView *) newContentView
{
    if( newContentView == contentView )
        return;
    
    [contentView removeFromSuperview];
    [contentView release];
    contentView = nil;
    
    if( newContentView != nil )
    {
        contentView = [newContentView retain];
        [self addSubview: newContentView];
        [self setNeedsLayout];
    }
}

-(PFCellContentView *) cellContentView
{
    if( [contentView isKindOfClass: [PFCellContentView class]] )
        return contentView;
    return nil;
}


#pragma mark -
#pragma mark Events

-(CGSize) sizeThatFits: (CGSize) size
{
    CGSize contentSize = size;
    contentSize.width -= ( kPFCalloutContentInset * 2 ) + kPFCalloutShadowSize;
    contentSize.height -= ( kPFCalloutContentInset * 2 ) + kPFCalloutShadowSize;
    contentSize.height = MAX( kPFCalloutMinimumContentHeight, contentSize.height );
    
    CGSize fitsize = [contentView sizeThatFits: contentSize];
    if( fitsize.height < kPFCalloutMinimumContentHeight )
        fitsize.height = kPFCalloutMinimumContentHeight;
    
    fitsize.width = MIN( size.width, fitsize.width + kPFCalloutContentInset * 2 );
    fitsize.height = MIN( size.height, fitsize.height + kPFCalloutContentInset * 2 );
    
    return fitsize;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint pointer = calloutLayer.pointerLocation;
    calloutLayer.pointerLocation = calloutLayer.position;
    CGRect bounds = CGRectMake( 0, 0, CGRectGetWidth( self.bounds ), CGRectGetHeight( self.bounds ) );
    
    contentView.frame = CGRectInset( bounds, kPFCalloutContentInset, kPFCalloutContentInset );
    
    bounds.size.height += kPFCalloutShadowSize;
    bounds.size.width += kPFCalloutShadowSize;
    
    calloutLayer.bounds = bounds;
    calloutLayer.position = CGPointMake( CGRectGetWidth( self.bounds ) / 2, 
                                         CGRectGetHeight( self.bounds ) / 2 + kPFCalloutShadowSize / 2 );
 
    calloutLayer.pointerLocation = pointer;
}

#pragma mark -
#pragma mark Actions

-(PFCalloutOrientation) resolveOrientationForTargetRect: (CGRect) rect inParentOfSize: (CGSize) size
{
    CGSize selfSize = [self sizeThatFits: size];
    
    
    // Try to fit above
    if( CGRectGetMinY( rect ) - selfSize.height > 0 )
        return PFCalloutOrientationAbove;
    
    // Try to fit below
    if( CGRectGetMaxY( rect ) + selfSize.height < size.height )
        return PFCalloutOrientationBelow;
    
    // Try to fit right
    if( CGRectGetMaxX( rect ) + selfSize.width < size.width )
        return PFCalloutOrientationRight;
    
    // Try to fit left
    if( CGRectGetMinX( rect ) - selfSize.width > 0 )
        return PFCalloutOrientationLeft;

    return PFCalloutOrientationNone;
}



-(void) pointAt: (CGPoint) point orientation: (PFCalloutOrientation) orientation inView: (UIView *) parentView
{
    
    if( parentView == nil )
        parentView = self.superview;
    
    // resolve auto orientation    
    if( orientation == PFCalloutOrientationAuto )
        orientation = [self resolveOrientationForTargetRect: CGRectMake( point.x, point.y, 1, 1 ) inParentOfSize: self.superview.bounds.size ];
    
    self.bounds = CGRectMake( 0, 0, CGRectGetWidth( parentView.bounds ), CGRectGetHeight( parentView.bounds ) );
    [self sizeToFit];
    
    CGPoint anchor;

    if( orientation == PFCalloutOrientationNone )
    {
        anchor = point;
    }
    else if( orientation == PFCalloutOrientationAbove || orientation == PFCalloutOrientationBelow )
    {
        CGFloat parentWidth = CGRectGetWidth( parentView.bounds );
        // If point is in left 1/3 of parent view, anchor on left
        if( point.x <= parentWidth / 3 )
            anchor.x = 0;
        
        // If point is in right 1/3 of parent view, anchor on right
        else if( point.x >= parentWidth - ( parentWidth / 3 ) )
            anchor.x = parentWidth - CGRectGetWidth( self.bounds ) - kPFCalloutShadowSize;
        
        // If point is in center 1/3 of parent view, anchor on right
        else
            anchor.x = ( parentWidth - CGRectGetWidth( self.bounds ) ) / 2;
        
        if( orientation == PFCalloutOrientationAbove )
        {
            anchor.y = point.y - CGRectGetHeight( self.bounds ) - kPFCalloutPointerSize;
            calloutLayer.pointerLocation = CGPointMake( point.x - anchor.x, CGRectGetHeight( self.bounds ) );
        }
        else
        {
            anchor.y = point.y + kPFCalloutPointerSize;
            calloutLayer.pointerLocation = CGPointMake( point.x - anchor.x, 0 );
        }

        self.center = CGPointMake( anchor.x + CGRectGetWidth( self.bounds ) / 2 + kPFCalloutShadowSize / 2, 
                                  anchor.y + CGRectGetHeight( self.bounds ) / 2 );
    }
    else
    {
        anchor.y = point.y;
        if( orientation == PFCalloutOrientationLeft )
        {
            anchor.x = point.x - CGRectGetWidth( self.bounds ) - kPFCalloutPointerSize;
            calloutLayer.pointerLocation = CGPointMake( CGRectGetWidth( self.bounds ) + kPFCalloutShadowSize / 2, 
                                                        point.y - anchor.y + CGRectGetHeight( self.bounds ) / 2 );
        }
        else
        {
            anchor.x = point.x + kPFCalloutPointerSize;
            calloutLayer.pointerLocation = CGPointMake( 0, point.y - anchor.y + CGRectGetHeight( self.bounds ) / 2 );
        }

        self.center = CGPointMake( anchor.x + CGRectGetWidth( self.bounds ) / 2, anchor.y );
    }
    
}

-(void) pointAt: (CGPoint) point orientation: (PFCalloutOrientation) orientation
{
    [self pointAt: point orientation: orientation inView: nil];
}

-(void) pointAtView: (UIView *) targetView orientation: (PFCalloutOrientation) orientation
{
    UIView * parentView = self.superview ? self.superview : targetView.superview;
    
    if( orientation == PFCalloutOrientationAuto )
        orientation = [self resolveOrientationForTargetRect: targetView.frame inParentOfSize: parentView.bounds.size];
    
    CGPoint point = targetView.center;
    switch( orientation )
    {
        case PFCalloutOrientationAbove:
            point.y -= CGRectGetHeight( targetView.bounds ) / 2;
            break;
        case PFCalloutOrientationBelow:
            point.y += CGRectGetHeight( targetView.bounds ) / 2;
            break;
        case PFCalloutOrientationLeft:
            point.x -= CGRectGetWidth( targetView.bounds ) / 2;
            break;
        case PFCalloutOrientationRight:
            point.x += CGRectGetWidth( targetView.bounds ) / 2;
            break;
    }
    
    [self pointAt: point orientation: orientation inView: parentView];
}

-(void) springIn
{
    [self.layer removeAllAnimations];
    
    [self.layer popSpringWithMinimumScale: 0 maximumScale: 1.1 tension: .5 duration: .5];
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath: @"transform.translation"];
    animation.fromValue = [NSValue valueWithCGPoint: CGPointMake( calloutLayer.pointerLocation.x - CGRectGetWidth( self.bounds ) / 2, 
                                                                  calloutLayer.pointerLocation.y - CGRectGetHeight( self.bounds ) / 2 )];
    animation.toValue = [NSValue valueWithCGPoint: CGPointZero];
    animation.duration = 0.075;
    
    [self.layer addAnimation: animation forKey: @"springIn_translate"];
                           
}

-(void) springOutAndRemove: (BOOL) remove
{
    [self.layer springOutWithMaximumScale: 1.5 
                                 duration: .25
                         completionTarget: remove ? self : nil 
                         completionAction: remove ? @selector(removeFromSuperview) : nil];
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath: @"transform.translation"];
    animation.fromValue = [NSValue valueWithCGPoint: CGPointZero];
    animation.toValue = [NSValue valueWithCGPoint: CGPointMake( calloutLayer.pointerLocation.x - CGRectGetWidth( self.bounds ) / 2, 
                                                                 calloutLayer.pointerLocation.y - CGRectGetHeight( self.bounds ) / 2 )];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = .40;
    
    [self.layer addAnimation: animation forKey: @"springOut_translate"];
}

-(void) tapped
{
    if( closeOnTap )
        [self springOutAndRemove: YES];
}

-(void) sendActionsForControlEvents: (UIControlEvents) events
{
    [super sendActionsForControlEvents: events];
}
@end