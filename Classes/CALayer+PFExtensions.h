//
//  CALayer+PFExtensions.h
//  Pants-Framework
//
//  Created by Paul Alexander on 10/16/10.
//  Copyright (c) 2010 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (PFExtensions)

-(void) popSpringWithMinimumScale: (CGFloat) minScale  
                     maximumScale: (CGFloat) maxScale 
                          tension: (CGFloat) tension 
                         duration: (CFTimeInterval) duration;

-(void) springOutWithMaximumScale: (CGFloat) maxScale
                         duration: (CFTimeInterval) duration
                 completionTarget: (id) completionTarget
                 completionAction: (SEL) completionAction;

@end

@interface PFAnimationCompletionDelegateDispatch : NSObject
{
@private
    SEL action;
    id target;
}

-(id) initWithTarget: (id) target action: (SEL) action;
+(id) dispatchWithTarget: (id) target action: (SEL) action;


@end
