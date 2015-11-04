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

#import "libsw/libSluthware/UIForceGestureRecognizerDelegate.h"

@class SWAcapellaTitlesCloneContainer;
@class SWAcapellaTitlesClone;

@class UIPanWithForceGestureRecognizer;
@class UILongPressWithForceGestureRecognizer;





@interface SWAcapella : NSObject <UIGestureRecognizerDelegate, UIDynamicAnimatorDelegate, UIForceGestureRecognizerDelegate>
{
}

+ (SWAcapella *)acapellaForObject:(id)object;
+ (void)setAcapella:(SWAcapella *)acapella ForObject:(id)object withPolicy:(objc_AssociationPolicy)policy;
+ (void)removeAcapella:(SWAcapella *)acapella;

- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;

@property (weak, nonatomic) id owner;

@property (weak, nonatomic) UIView *referenceView;
@property (weak, nonatomic) UIView *titles;

@property (strong, nonatomic) NSString *prefKeyPrefix;
@property (strong, nonatomic) NSString *prefApplication;

@property (strong, nonatomic) SWAcapellaTitlesCloneContainer *titlesCloneContainer;

@property (readonly, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readonly, strong, nonatomic) UITapGestureRecognizer *tap2;
@property (readonly, strong, nonatomic) UIPanWithForceGestureRecognizer *pan;
@property (readonly, strong, nonatomic) UIPanWithForceGestureRecognizer *pan2;
@property (readonly, strong, nonatomic) UILongPressWithForceGestureRecognizer *press;
@property (readonly, strong, nonatomic) UILongPressWithForceGestureRecognizer *press2;

- (void)refreshTitleClone;

- (void)finishWrapAround;
- (void)pulseAnimateView;

@end




