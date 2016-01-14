//
//  SWAcapella.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <objc/runtime.h>

#import "SWAcapellaDelegate.h"

@class SWAcapellaTitlesCloneContainer;
@class SWAcapellaTitlesClone;





@interface SWAcapella : NSObject <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate>
{
}


+ (SWAcapella *)acapellaForObject:(id)object;
+ (void)setAcapella:(SWAcapella *)acapella ForObject:(id)object withPolicy:(objc_AssociationPolicy)policy;
+ (void)removeAcapella:(SWAcapella *)acapella;


// This is the object which keeps a strong reference to this acapella associated object
@property (weak, nonatomic) NSObject<SWAcapellaDelegate> *owner;

@property (weak, nonatomic) UIView *referenceView;
@property (weak, nonatomic) UIView *titles;

@property (strong, nonatomic) SWAcapellaTitlesCloneContainer *titlesCloneContainer;

@property (readonly, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readonly, strong, nonatomic) UIPanGestureRecognizer *pan;

/**
 *  Init an acapella with a reference view. Update the newly created acapellas values before it is fully initialized in preInitializeAction
 *
 *  @param referenceView
 *  @param preInitializeAction
 *
 *  @return SWAcapella
 */
- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;

- (void)refreshTitleClone;

- (void)finishWrapAround;
- (void)pulseAnimateView;

@end




