//
//  PFCalloutView.h
//  Disney Treasure Hunt
//
//  Created by Paul Alexander on 10/15/10.
//  Copyright (c) 2010 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFCalloutLayer.h"
#import "PFCellContentView.h"


@interface PFCalloutView : UIControl 
{

@private
    PFCalloutLayer * calloutLayer;

    BOOL closeOnTap;
    
    
    PFCellContentView * contentView;
}

@property( nonatomic, assign ) BOOL closeOnTap;


@property( nonatomic, retain ) UIView * contentView;
@property( nonatomic, readonly ) PFCellContentView * cellContentView;
          

-(void) pointAt: (CGPoint) point orientation: (PFCalloutOrientation) orientation;
-(void) pointAtView: (UIView *) targetView orientation: (PFCalloutOrientation) orientation;
-(void) springIn;
-(void) springOutAndRemove: (BOOL) remove;
@end