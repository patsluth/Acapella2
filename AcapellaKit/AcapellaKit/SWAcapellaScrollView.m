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

@synthesize isPerformingWrapAroundAnimation = _isPerformingWrapAroundAnimation;

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
        //self.backgroundColor = [UIColor magentaColor];
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        
        self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.testView.backgroundColor = [UIColor blackColor];
        self.testView.alpha = 0.2;
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
    
    [self resetContentOffset:NO];
}

#pragma mark SWAcapellaScrollViewProtocol

- (CGPoint)defaultContentOffset
{
    return CGPointMake(self.contentSize.width / 2 - (self.frame.size.width / 2), 0);
}

- (void)resetContentOffset:(BOOL)animated
{
    //reset
    self.currentVelocity = CGPointZero;
    
    self.isPerformingWrapAroundAnimation = YES;
    
    [UIView animateWithDuration:animated ? 1.0 : 0.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.contentOffset = [self defaultContentOffset];
                     }completion:^(BOOL finished){
                         self.isPerformingWrapAroundAnimation = NO;
                         self.userInteractionEnabled = YES;
                     }];
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
    if (self.isPerformingWrapAroundAnimation){
        return;
    }
    
    [self stopWrapAroundFallback];
    
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




