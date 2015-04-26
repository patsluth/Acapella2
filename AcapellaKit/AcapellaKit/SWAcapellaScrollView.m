//
//  SWAcapellaScrollView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaScrollView.h"

#import "UIScrollView+SW.h"

@interface SWAcapellaScrollView()
{
}

@property (strong, nonatomic) NSTimer *wrapAroundFallback;

#ifdef DEBUG
@property (strong, nonatomic) UIView *testView;
#endif

@end





@implementation SWAcapellaScrollView

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self) {
        
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.directionalLockEnabled = YES;
        self.scrollsToTop = NO;
        self.alwaysBounceVertical = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
#ifdef DEBUG
        //self.backgroundColor = [UIColor magentaColor];
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        
        self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.testView.backgroundColor = [UIColor blackColor];
        self.testView.alpha = 0.1;
        [self addSubview:self.testView];
#endif
        
        self.isAnimating = NO;
    }
    
    return self;
}

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    
    self.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height * 3);
    
#ifdef DEBUG
    if (self.testView) {
        self.testView.center = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    }
#endif
    
    [self resetContentOffset:NO];
}

#pragma mark - SWAcapellaScrollViewProtocol

- (CGPoint)defaultContentOffset
{
    return CGPointMake((self.contentSize.width / 2.0) - CGRectGetMidX(self.frame),
                       (self.contentSize.height / 2.0) - CGRectGetMidY(self.frame));
}

- (void)resetContentOffset:(BOOL)animated
{
    void (^_animationContent)() = ^() {
        
        self.contentOffset = self.defaultContentOffset;
        
    };
    
    void (^_postAnimation)() = ^() {
        
        self.isAnimating = NO;
        
    };
    
    
    
    
    if (self.isTracking) {
        return;
    }
    
    self.userInteractionEnabled = YES;
    
    self.isAnimating = animated;
    
    if (animated) {
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             _animationContent();
                         }completion:^(BOOL finished) {
                             _postAnimation();
                         }];
        
    } else {
        
        _animationContent();
        _postAnimation();
        
    }
}

- (void)startWrapAroundFallback
{
    [self stopWrapAroundFallback];
    
    self.wrapAroundFallback = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(finishWrapAroundAnimation)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void)stopWrapAroundFallback
{
    if (self.wrapAroundFallback) {
        [self.wrapAroundFallback invalidate];
        self.wrapAroundFallback = nil;
    }
}

- (void)finishWrapAroundAnimation
{
    [self stopWrapAroundFallback];
    
    if (self.isAnimating || self.isTracking) {
        return;
    }
    
    SWPage page = [self page];
    
    //make content offset the on the oposite side, to appear as if we wrapped around
    if (page.x == 0 && page.y == 1) { //right
        self.contentOffset = CGPointMake(self.bounds.size.width * 2.0, self.defaultContentOffset.y);
    } else if (page.x == 2 && page.y == 1) { //left
        self.contentOffset = CGPointMake(0, self.defaultContentOffset.y);
    } else if (page.x == 1 && page.y == 0) { //bottom
        self.contentOffset = CGPointMake(self.defaultContentOffset.x, self.bounds.size.height * 2.0);
    } else if (page.x == 1 && page.y == 2) { //top
        self.contentOffset = CGPointMake(self.defaultContentOffset.x, 0);
    } else {
        return;
    }
    
    
    [self resetContentOffset:YES];
}

@end




