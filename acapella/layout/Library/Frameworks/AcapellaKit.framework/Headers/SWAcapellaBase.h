//
//  SWAcapellaBase.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWAcapellaActionIndicatorController;

typedef enum {
    SW_DIRECTION_NONE = 0,
    SW_DIRECTION_LEFT = 1,
    SW_DIRECTION_RIGHT = 2,
    SW_DIRECTION_UP = 3,
    SW_DIRECTION_DOWN = 4
} SW_SCROLL_DIRECTION;






@protocol SWAcapellaDelegate <NSObject>

@required
- (void)swAcapellaOnTap:(CGPoint)percentage;
- (void)swAcapellaOnSwipe:(SW_SCROLL_DIRECTION)direction;
- (void)swAcapellaOnLongPress:(CGPoint)percentage;

@end






@interface SWAcapellaBase : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) id <SWAcapellaDelegate> delegateAcapella;

@property (readwrite, nonatomic) SW_SCROLL_DIRECTION currentScrollDirection;
@property (readwrite, nonatomic) CGPoint previousScrollOffset;

@property (strong, nonatomic) UIScrollView *scrollview;
@property (readonly, strong, nonatomic) SWAcapellaActionIndicatorController *actionIndicatorController;

- (void)resetContentOffset;
- (void)finishWrapAroundAnimation;
- (void)stopWrapAroundFallback;

@end




