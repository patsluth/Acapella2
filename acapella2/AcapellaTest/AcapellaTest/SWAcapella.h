//
//  SWAcapella.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface SWAcapella : NSObject <UIDynamicAnimatorDelegate>
{
}

+ (SWAcapella *)acapellaForOwner:(id)owner;
+ (void)setAcapella:(SWAcapella *)acapella ForOwner:(id)owner;
+ (void)removeAcapella:(SWAcapella *)acapella;

@property (weak, nonatomic) id owner;

- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;
@property (weak, nonatomic) UIView *referenceView;

@property (readonly, strong, nonatomic) UIPanGestureRecognizer *pan;

@property (weak, nonatomic) UIView *titles;
@property (weak, nonatomic) UIView *topSlider;
@property (weak, nonatomic) UIView *bottomSlider;

@property (strong, nonatomic) UIDynamicAnimator *animator_titles;
@property (strong, nonatomic) UIDynamicAnimator *animator_topSlider;
@property (strong, nonatomic) UIDynamicAnimator *animator_bottomSlider;

@end




