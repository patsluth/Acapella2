//
//  SWAcapellaScrollView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaScrollView.h"
#import "libsw/sluthwareios/sluthwareios.h"

@interface SWAcapellaScrollView()
{
}

@property (strong, nonatomic) NSTimer *wrapAroundFallback;

#ifdef DEBUG
@property (strong, nonatomic) UIView *testView;
#endif

@end





@implementation SWAcapellaScrollView

#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.directionalLockEnabled = YES;
        self.scrollsToTop = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
#ifdef DEBUG
        self.backgroundColor = [UIColor magentaColor];
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        
        self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.testView.backgroundColor = [UIColor blackColor];
        self.testView.alpha = 0.1;
        [self addSubview:self.testView];
#endif
        
        self.previousScrollOffset = CGPointZero;
        self.isAnimating = NO;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    
    [self resetContentOffset:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
#ifdef DEBUG
    if (self.testView){
        self.testView.center = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    }
#endif
}

#pragma mark SWAcapellaScrollViewProtocol

- (CGPoint)defaultContentOffset
{
    return CGPointMake(self.contentSize.width / 2 - (self.frame.size.width / 2), 0);
}

- (void)resetContentOffset:(BOOL)animated
{
    void (^_animationContent)() = ^(){
        
        self.contentOffset = [self defaultContentOffset];
        
    };
    
    void (^_postAnimation)() = ^(){
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
            [self.delegate scrollViewDidEndScrollingAnimation:self];
        }
        
        self.isAnimating = NO;
        
    };
    
    
    
    
    if (self.isTracking){
        return;
    }
    
    self.currentVelocity = CGPointZero;
    self.userInteractionEnabled = YES;
    
    self.isAnimating = animated;
    
    if (animated){
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             _animationContent();
                         }completion:^(BOOL finished){
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
    if (self.wrapAroundFallback){
        [self.wrapAroundFallback invalidate];
        self.wrapAroundFallback = nil;
    }
}

- (void)finishWrapAroundAnimation
{
    [self stopWrapAroundFallback];
    
    if (self.isAnimating || self.isTracking){
        return;
    }
    
    SWPage page = [self page];
    
    //make content offset the on the oposite side, to appear as if we wrapped around
    if (page.x == 0 && page.y == 0){ //left
        self.contentOffset = CGPointMake(self.frame.size.width * 2, 0);
    } else if (page.x == 2 && page.y == 0) { //right
        self.contentOffset = CGPointMake(0, 0);
    } else {
        [self resetContentOffset:NO];
        return;
    }
    
    
    [self resetContentOffset:YES];
}

@end




