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

@class SWAcapellaTitlesCloneContainer;
@class SWAcapellaTitlesClone;





@interface SWAcapella : NSObject <UIDynamicAnimatorDelegate>
{
}

+ (SWAcapella *)acapellaForObject:(id)object;
+ (void)setAcapella:(SWAcapella *)acapella ForObject:(id)object withPolicy:(objc_AssociationPolicy)policy;
+ (void)removeAcapella:(SWAcapella *)acapella;

- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;

@property (weak, nonatomic) id owner;

@property (weak, nonatomic) UIView *referenceView;
@property (weak, nonatomic) UIView *titles;
@property (weak, nonatomic) UIView *topSlider;
@property (weak, nonatomic) UIView *bottomSlider;

@property (strong, nonatomic) NSString *prefKeyPrefix;

@property (strong, nonatomic) SWAcapellaTitlesCloneContainer *titlesCloneContainer;

@property (readonly, strong, nonatomic) UIPanGestureRecognizer *pan;
@property (readonly, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readonly, strong, nonatomic) UILongPressGestureRecognizer *press;

- (void)refreshTitleClone;

- (void)finishWrapAround;
- (void)pulseAnimateView:(UIView *)view;

+ (NSString *)prefKeyByDrillingUpFromView:(UIView *)view;

@end




