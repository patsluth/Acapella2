//
//  SWAcapellaScrollView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaScrollView.h"
#import "sluthwareios.h"

@interface SWAcapellaScrollView()
{
}

#ifdef DEBUG
@property (strong, nonatomic) UIView *testView;
#endif

@end

@implementation SWAcapellaScrollView

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.canCancelContentTouches = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.directionalLockEnabled = YES;
        
#ifdef DEBUG
        self.backgroundColor = [UIColor magentaColor];
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        
        self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.testView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.testView];
#endif
        
        self.previousScrollOffset = CGPointZero;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    
    [self resetContentOffset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
#ifdef DEBUG
    [self.testView setCenter:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
#endif
}

- (void)resetContentOffset
{
    self.contentOffset = CGPointMake(self.contentSize.width / 2 - (self.frame.size.width / 2), 0);
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
    
    SWPage page = [self page];
    
    CGPoint targetContentOffset = CGPointMake(self.frame.size.width, 0);
    
    //make content offset the on the oposite side, to appear as if we wrapped around
    if (page.x == 0 && page.y == 0){ //left
        self.contentOffset = CGPointMake(self.frame.size.width * 2, 0);
    } else if (page.x == 2 && page.y == 0) { //right
        self.contentOffset = CGPointMake(0, 0);
    } else {
        [self resetContentOffset];
        self.userInteractionEnabled = YES;
        return;
    }
    
    if (self.currentVelocity.x == 0.0 && self.currentVelocity.y == 0.0){
        self.currentVelocity = CGPointMake(self.decelerationRate, self.decelerationRate);
    }
    
    //calcualte distance we need to animate
    CGPoint distance = CGPointMake(fabs(self.contentOffset.x - targetContentOffset.x),
                                   self.contentOffset.y - targetContentOffset.y);
    //get total animation time using the points/ms we got from
    //scrollViewWillEndDragging with velocity (converted to seconds)
    CGFloat animationTime = ((distance.x == 0) ? distance.y : distance.x /
                             fabs((self.currentVelocity.x == 0) ?
                                  self.currentVelocity.y : self.currentVelocity.x)) / 1000;
    
    //reset
    self.currentVelocity = CGPointZero;
    
    [UIView animateWithDuration:animationTime
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.contentOffset = targetContentOffset;
                     }completion:^(BOOL finished){
                         self.userInteractionEnabled = YES;
                     }];
}

@end




