//
//  SWAcapellaActionIndicator.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaActionIndicator.h"
#import <libsw/sluthwareios/sluthwareios.h>

@interface SWAcapellaActionIndicator()
{
}

@property (readwrite, nonatomic) BOOL isAnimatingToShow;
@property (readwrite, nonatomic) BOOL isShowing;
@property (readwrite, nonatomic) BOOL isAnimatingToHide;

@property (strong, nonatomic) NSTimer *initiateHideTimer;

//internal. override in subclasses for custom animations
- (void)setupViewForShowAnimation;
- (void)performShowAnimation;
- (void)setupViewForHideAnimation;
- (void)performHideAnimation;

@end

@implementation SWAcapellaActionIndicator

- (id)initWithFrame:(CGRect)frame andActionIndicatorIdentifier:(NSString *)identifier
{
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.alpha = 1.0;
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleBottomMargin);
        
        self.actionIndicatorIdentifier = identifier;
        
        self.actionIndicatorAnimationInTime = SWACAPELLA_ACTIONINDICATOR_DEFAULT_ANIMATION_IN_TIME;
        self.actionIndicatorDisplayTime = SWACAPELLA_ACTIONINDICATOR_DEFAULT_DISPLAY_TIME;
        self.actionIndicatorAnimationOutTime = SWACAPELLA_ACTIONINDICATOR_DEFAULT_ANIMATION_OUT_TIME;
        
        self.isAnimatingToShow = NO;
        self.isShowing = NO;
        self.isAnimatingToHide = NO;
    }
    
    return self;
}

- (void)showAnimated:(BOOL)animated
{
    if (self.actionIndicatorDelegate){
        [self.actionIndicatorDelegate actionIndicatorWillShow:self];
    }
    
    if (!self.isAnimatingToHide){
        [self setupViewForShowAnimation];
    }
    
    self.isAnimatingToShow = YES;
    self.isShowing = NO;
    self.isAnimatingToHide = NO;
    
    [UIView animateWithDuration:animated ? self.actionIndicatorAnimationInTime : 0.0
                          delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState |
                                 UIViewAnimationOptionAllowUserInteraction |
                                 UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         [self performShowAnimation];
                     }
                     completion:^(BOOL finished){
                         
                         if (finished){
                             
                             self.isAnimatingToShow = NO;
                             self.isShowing = YES;
                             self.isAnimatingToHide = NO;
                             
                             if (self.actionIndicatorDelegate){
                                 [self.actionIndicatorDelegate actionIndicatorDidShow:self];
                             }
                             
                             [self startInitiateHideTimer:self.actionIndicatorDisplayTime animated:animated];
                         }
                         
                     }];
}

- (void)setupViewForShowAnimation
{
    self.alpha = 1.0;
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0001, 0.0001);
}

- (void)performShowAnimation
{
    self.alpha = 1.0;
    //make sure we keep our original rotation
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
}

- (void)delayBySeconds:(CGFloat)seconds
{
    if (self.isShowing){
        
        if (self.initiateHideTimer && self.initiateHideTimer.isValid){
            [self stopInitiateHideTimer];
        }
        
        [self startInitiateHideTimer:seconds animated:YES];
        
    } else if (self.isAnimatingToShow){
        
    } else if (self.isAnimatingToHide){
        
        CALayer *presentation = (CALayer *)self.layer.presentationLayer;
        [self.layer removeAllAnimations];
        self.layer.transform = [presentation transform];
        
        [self showAnimated:YES];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    [self stopInitiateHideTimer];
    
    if (self.actionIndicatorDelegate){
        [self.actionIndicatorDelegate actionIndicatorWillHide:self];
    }
    
    [self setupViewForHideAnimation];
    
    self.isAnimatingToShow = NO;
    self.isShowing = NO;
    self.isAnimatingToHide = YES;
    
    [UIView animateWithDuration:animated ? self.actionIndicatorAnimationOutTime : 0.0
                          delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState |
                                 UIViewAnimationOptionAllowUserInteraction |
                                 UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         [self performHideAnimation];
                     }
                     completion:^(BOOL finished){
                         
                         if (finished){
                             
                             self.isAnimatingToShow = NO;
                             self.isShowing = NO;
                             self.isAnimatingToHide = NO;
                             
                             if (self.actionIndicatorDelegate){
                                 [self.actionIndicatorDelegate actionIndicatorDidHide:self];
                             }
                         }
                         
                     }];
}

- (void)setupViewForHideAnimation
{
}

- (void)performHideAnimation
{
    self.alpha = 1.0;
    //make sure we keep our original rotation
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0001, 0.0001);
}

#pragma mark Hide Timer

- (void)startInitiateHideTimer:(CGFloat)time animated:(BOOL)animated
{
    if (self.initiateHideTimer && self.initiateHideTimer.isValid){
        return;
    }
    
    SEL selector = @selector(hideAnimated:);
    
    NSMethodSignature *signature = [SWAcapellaActionIndicator instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation setArgument:&animated atIndex:2];
    
    self.initiateHideTimer = [NSTimer scheduledTimerWithTimeInterval:time invocation:invocation repeats:NO];
}

- (void)stopInitiateHideTimer
{
    if (self.initiateHideTimer){
        [self.initiateHideTimer invalidate];
        self.initiateHideTimer = nil;
    }
}

@end




