//
//  SWAcapellaBase.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaBase.h"
#import "SWAcapellaActionIndicator.h"

#import "sluthwareios.h"

@interface SWAcapellaBase()
{
}

//gesture recognizers
@property (strong, nonatomic) UITapGestureRecognizer *oneFingerTap;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeDown;

//wrap around helpers
@property (readwrite, nonatomic) CGPoint currentVelocity;
@property (strong, nonatomic) NSTimer *wrapAroundFallback;

//action indicator
@property (readwrite, strong, nonatomic) SWAcapellaActionIndicator *actionIndicator;

#ifdef DEBUG

@property (strong, nonatomic) UILabel *testLabel;

#endif

@end

@implementation SWAcapellaBase

#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.scrollview = [[UIScrollView alloc] init];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.scrollview];
        
        self.scrollview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.scrollview.contentSize = self.scrollview.frame.size;
        self.scrollview.delegate = self;
        
        self.scrollview.decelerationRate = UIScrollViewDecelerationRateFast;
        self.scrollview.canCancelContentTouches = YES;
        self.scrollview.showsHorizontalScrollIndicator = NO;
        self.scrollview.showsVerticalScrollIndicator = NO;
        self.scrollview.pagingEnabled = YES;
        self.scrollview.directionalLockEnabled = YES;
        
#ifdef DEBUG
        self.backgroundColor = [UIColor redColor];
        self.scrollview.backgroundColor = [UIColor yellowColor];
        
        self.scrollview.showsHorizontalScrollIndicator = YES;
        self.scrollview.showsVerticalScrollIndicator = YES;
        
        self.testLabel = [[UILabel alloc] init];

        self.testLabel.text = @"Test Label";
        [self.testLabel sizeToFit];
        
        [self.testLabel setCenter:CGPointMake(self.scrollview.contentSize.width / 2, self.scrollview.contentSize.height / 2)];
        [self.scrollview addSubview:self.testLabel];
#endif
        
        [self initGestureRecognizers];
        
        self.currentScrollDirection = SW_DIRECTION_NONE;
        self.previousScrollOffset = CGPointZero;
        
        //action indicator
        self.actionIndicator = [[SWAcapellaActionIndicator alloc] init];
        [self addSubview:self.actionIndicator];
        
        [self resetContentOffset];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint originalContentOffset = self.scrollview.contentOffset;
    
    self.scrollview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.scrollview.contentSize = CGSizeMake(self.scrollview.frame.size.width * 3,
                                             self.scrollview.frame.size.height * 3);
    
    self.scrollview.contentOffset = originalContentOffset;
    
#ifdef DEBUG
    //keep centered in the content view
    [self.testLabel setCenter:CGPointMake(self.scrollview.contentSize.width / 2, self.scrollview.contentSize.height / 2)];
#endif
    
    self.actionIndicator.frame = CGRectMake(0,
                                                    self.frame.size.height / 10,
                                                    self.frame.size.width / 4,
                                                    self.frame.size.height / 5);
    [self.actionIndicator setCenterX:self.frame.size.width / 2];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self resetContentOffset];
}

- (void)initGestureRecognizers
{
    [self resetGestureRecognizers];
    
    self.oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(onTap:)];
    self.oneFingerTap.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.oneFingerTap];
    
    
    
    
    
    self.swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(onSwipeUp:)];
    self.swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    self.swipeUp.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.swipeUp];
    
    
    
    
    
    self.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(onSwipeDown:)];
    self.swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    self.swipeDown.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.swipeDown];
    
    
    
    
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(onPress:)];
    self.longPress.minimumPressDuration = 0.7;
    [self addGestureRecognizer:self.longPress];
}

- (void)resetGestureRecognizers
{
    if (self.oneFingerTap){
        [self.oneFingerTap removeTarget:self action:@selector(onTap:)];
        [self removeGestureRecognizer:self.oneFingerTap];
        self.oneFingerTap = nil;
    }
    if (self.swipeUp){
        [self.swipeUp removeTarget:self action:@selector(onSwipeUp:)];
        [self removeGestureRecognizer:self.swipeUp];
        self.swipeUp = nil;
    }
    if (self.swipeDown){
        [self.swipeDown removeTarget:self action:@selector(onSwipeDown:)];
        [self removeGestureRecognizer:self.swipeDown];
        self.swipeDown = nil;
    }
    if (self.longPress){
        [self.longPress removeTarget:self action:@selector(onPress:)];
        [self removeGestureRecognizer:self.longPress];
        self.longPress = nil;
    }
}

- (void)resetContentOffset
{
    //make sure we are centered
    if (self.scrollview){
        self.scrollview.contentOffset = CGPointMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height);
    }
}

#pragma mark ScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollview.contentOffset.x >= self.previousScrollOffset.x &&
        self.scrollview.contentOffset.y == self.scrollview.contentSize.height / 3){
        
        self.currentScrollDirection = SW_DIRECTION_LEFT;
        
    } else if (self.scrollview.contentOffset.x < self.previousScrollOffset.x &&
               self.scrollview.contentOffset.y == self.scrollview.contentSize.height / 3){
        
        self.currentScrollDirection = SW_DIRECTION_RIGHT;
        
    } else if (self.scrollview.contentOffset.x == self.scrollview.contentSize.width / 3 &&
               self.scrollview.contentOffset.y >= self.previousScrollOffset.y){
        
        self.currentScrollDirection = SW_DIRECTION_UP;
        
    } else if (self.scrollview.contentOffset.x == self.scrollview.contentSize.width / 3 &&
               self.scrollview.contentOffset.y <= self.previousScrollOffset.y){
        
        self.currentScrollDirection = SW_DIRECTION_DOWN;
        
    } else {
        
        self.currentScrollDirection = SW_DIRECTION_NONE;
        
    }
    
    //lock to either horizontal or vertical if we are dragging (prevent the diagonal drag)
    if (self.scrollview.isTracking && self.currentScrollDirection == SW_DIRECTION_NONE){
        self.scrollview.contentOffset = CGPointMake(self.scrollview.contentOffset.x, self.scrollview.contentSize.height / 3);
    }
    
    self.previousScrollOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.currentVelocity = velocity;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.delegateAcapella){
        return;
    }
    
    CGPoint page = [self.scrollview page];
    
    BOOL shouldAnimated = (page.x != 1 || page.y != 1); //centered already
    
    if (shouldAnimated){
        
        self.scrollview.userInteractionEnabled = NO;
        
        SW_SCROLL_DIRECTION direction = SW_DIRECTION_NONE;
        
        if (page.x == 0 && page.y == 1){
            direction = SW_DIRECTION_LEFT;
        } else if (page.x == 2 && page.y == 1) {
            direction = SW_DIRECTION_RIGHT;
        } else if (page.x == 1 && page.y == 0){
            direction = SW_DIRECTION_UP;
        } else if (page.x == 1 && page.y == 2) {
            direction = SW_DIRECTION_DOWN;
        }
        
        [self.delegateAcapella swAcapellaOnSwipe:direction];
        
        [self startWrapAroundFallback];
        
    } else {
        [self resetContentOffset];
    }
}

- (void)startWrapAroundFallback
{
    [self stopWrapAroundFallback];
    
    self.wrapAroundFallback = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                               target:self
                                                             selector:@selector(finishWrapAroundAnimation)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void)stopWrapAroundFallback
{
    if (self.wrapAroundFallback){
        [self.wrapAroundFallback invalidate];
        self.wrapAroundFallback = nil;
    }
}

- (void)finishWrapAroundAnimation
{
    [self stopWrapAroundFallback];
    
    self.scrollview.userInteractionEnabled = YES;
    
    CGPoint page = [self.scrollview page];
    
    CGPoint targetContentOffset = CGPointMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height);
    
    //make content offset the on the oposite side, to appear as if we wrapped around
    if (page.x == 0 && page.y == 1){ //left
        self.scrollview.contentOffset = CGPointMake(self.scrollview.frame.size.width * 2, self.scrollview.frame.size.height);
    } else if (page.x == 2 && page.y == 1) { //right
        self.scrollview.contentOffset = CGPointMake(0, self.scrollview.frame.size.height);
    } else if (page.x == 1 && page.y == 0){ //up
        self.scrollview.contentOffset = CGPointMake(self.scrollview.frame.size.width, self.scrollview.frame.size.height * 2);
    } else if (page.x == 1 && page.y == 2) { //down
        self.scrollview.contentOffset = CGPointMake(self.scrollview.frame.size.width, 0);
    } else {
        [self resetContentOffset];
        return;
    }
    
    if (self.currentVelocity.x == 0.0 && self.currentVelocity.y == 0.0){
        self.currentVelocity = CGPointMake(self.scrollview.decelerationRate, self.scrollview.decelerationRate);
    }
    
    //calcualte distance we need to animate
    CGPoint distance = CGPointMake(fabs(self.scrollview.contentOffset.x - targetContentOffset.x),
                                   self.scrollview.contentOffset.y - targetContentOffset.y);
    //get total animation time using the points/ms we got from
    //scrollViewWillEndDragging with velocity (converted to seconds)
    CGFloat animationTime = ((distance.x == 0) ? distance.y : distance.x /
                             fabs((self.currentVelocity.x == 0) ? self.currentVelocity.y : self.currentVelocity.x)) / 1000;
    
    //reset
    self.currentVelocity = CGPointZero;
    
    [UIView animateWithDuration:animationTime
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.scrollview.contentOffset = targetContentOffset;
                     }completion:^(BOOL finished){
                         
                     }];
}

#pragma mark Gesture Recognizers

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded){
        
        CGFloat xPercentage = [tap locationInView:self].x / self.frame.size.width;
        CGFloat yPercentage = [tap locationInView:self].y / self.frame.size.height;
        
        if (self.delegateAcapella){
            [self.delegateAcapella swAcapellaOnTap:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

- (void)onSwipeUp:(UISwipeGestureRecognizer *)swipe
{
    if (self.delegateAcapella){
        [self.delegateAcapella swAcapellaOnSwipe:SW_DIRECTION_UP];
    }
}

- (void)onSwipeDown:(UISwipeGestureRecognizer *)swipe
{
    if (self.delegateAcapella){
        [self.delegateAcapella swAcapellaOnSwipe:SW_DIRECTION_DOWN];
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)press
{
    if (press.state == UIGestureRecognizerStateBegan){
        
        CGFloat xPercentage = [press locationInView:self].x / self.frame.size.width;
        CGFloat yPercentage = [press locationInView:self].y / self.frame.size.height;
        
        if (self.delegateAcapella){
            [self.delegateAcapella swAcapellaOnLongPress:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

@end




