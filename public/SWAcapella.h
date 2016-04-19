//
//  SWAcapella.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

@import UIKit;
@import Foundation;

#import <objc/runtime.h>

#import "SWAcapellaDelegate.h"

#import <UIKit/UIInteractionProgressObserver.h>





@interface SWAcapella : NSObject <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate, UIInteractionProgressObserver>
{
}


+ (SWAcapella *)acapellaForObject:(id)object;
+ (void)setAcapella:(SWAcapella *)acapella ForObject:(id)object withPolicy:(objc_AssociationPolicy)policy;
+ (void)removeAcapella:(SWAcapella *)acapella;


// This is the object which keeps a strong reference to this acapella associated object
@property (weak, nonatomic) UIViewController<SWAcapellaDelegate> *owner;

@property (weak, nonatomic) UIView *referenceView;
@property (weak, nonatomic) UIView *titles;

@property (strong, nonatomic, readonly) UITapGestureRecognizer *tap;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *pan;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *press;

/**
 *  Init an acapella with a reference view. Update the newly created acapellas values before it is fully initialized in preInitializeAction
 *
 *  @param referenceView
 *  @param preInitializeAction
 *
 *  @return SWAcapella
 */
- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;

/**
 *  Tell Acapella titles view is ready to wrap around and snap back to centre
 */
- (void)finishWrapAround;
/**
 *  Perform animation that 'pulses' the view. (Increase then decrease in size, like a hearbeat)
 */
- (void)pulseAnimateView;

@end




