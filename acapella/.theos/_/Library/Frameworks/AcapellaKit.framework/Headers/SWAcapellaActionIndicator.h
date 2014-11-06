//
//  SWAcapellaActionIndicator.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWACAPELLA_ACTIONINDICATOR_DEFAULT_ANIMATION_IN_TIME 0.1
#define SWACAPELLA_ACTIONINDICATOR_DEFAULT_DISPLAY_TIME 1.2
#define SWACAPELLA_ACTIONINDICATOR_DEFAULT_ANIMATION_OUT_TIME 0.4

@class SWAcapellaActionIndicator;

@protocol SWAcapellaActionIndicatorDelegate <NSObject>

@required
- (void)actionIndicatorWillShow:(SWAcapellaActionIndicator *)actionIndicator; //before it starts its show animation
- (void)actionIndicatorDidShow:(SWAcapellaActionIndicator *)actionIndicator; //after it has finished its show animation
- (void)actionIndicatorWillHide:(SWAcapellaActionIndicator *)actionIndicator; //before it starts its hide animation
- (void)actionIndicatorDidHide:(SWAcapellaActionIndicator *)actionIndicator; //after it has finished its hide animation

@end






@interface SWAcapellaActionIndicator : UIView

@property (weak, nonatomic) id<SWAcapellaActionIndicatorDelegate> actionIndicatorDelegate;

@property (strong, nonatomic) NSString *actionIndicatorIdentifier;
//set the following if you want to override default values
@property (readwrite, nonatomic) CGFloat actionIndicatorAnimationInTime;
@property (readwrite, nonatomic) CGFloat actionIndicatorDisplayTime;
@property (readwrite, nonatomic) CGFloat actionIndicatorAnimationOutTime;

@property (readonly, nonatomic) BOOL isAnimatingToShow;
@property (readonly, nonatomic) BOOL isShowing;
@property (readonly, nonatomic) BOOL isAnimatingToHide;

- (id)initWithFrame:(CGRect)frame andActionIndicatorIdentifier:(NSString *)identifier;

- (void)showAnimated:(BOOL)animated;
- (void)delayBySeconds:(CGFloat)seconds;
- (void)hideAnimated:(BOOL)animated;

@end




