//
//  SWAcapellaTableView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTableView.h"
#import <libsw/sluthwareios/sluthwareios.h>

@interface SWAcapellaTableView()
{
}

@property (strong, nonatomic) NSTimer *wrapAroundFallback;

@end





@implementation SWAcapellaTableView

#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.bounces = NO;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        
        self.scrollsToTop = NO;
        
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self resetContentOffset:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark SWAcapellaScrollViewProtocol

- (NSIndexPath *)defaultIndexPath;
{
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

- (void)resetContentOffset:(BOOL)animated
{
    if (self.numberOfSections == 1 && [self numberOfRowsInSection:0] > 3){
        [self scrollToRowAtIndexPath:[self defaultIndexPath] //row for our main acapella view
                    atScrollPosition:UITableViewScrollPositionMiddle
                            animated:animated];
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
    
    NSIndexPath *currentIndexPath = [self indexPathForRowAtPoint:self.contentOffset];
    
    
    //set up so we wrap around
    if (currentIndexPath.section == 0 && currentIndexPath.row <= 0){
        
        //bottom
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self numberOfRowsInSection:0] -1
                                                        inSection:0]
                    atScrollPosition:UITableViewScrollPositionBottom
                            animated:NO];
        
    } else if (currentIndexPath.section == 0 && currentIndexPath.row == [self numberOfRowsInSection:0] - 1){
        
        //top
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                    atScrollPosition:UITableViewScrollPositionTop
                            animated:NO];
        
    } else {
        
        [self resetContentOffset:NO];
        self.userInteractionEnabled = YES;
        return;
        
    }
    
    if (self.currentVelocity.x == 0.0 && self.currentVelocity.y == 0.0){
        self.currentVelocity = CGPointMake(self.decelerationRate, self.decelerationRate);
    }
    
    CGRect mainAcapellaRect = [self rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    //calcualte distance we need to animate
    CGPoint distance = CGPointMake(fabs(self.contentOffset.x - mainAcapellaRect.origin.x),
                                   self.contentOffset.y - mainAcapellaRect.origin.y);
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
                         [self resetContentOffset:YES];
                     }completion:^(BOOL finished){
                         self.userInteractionEnabled = YES;
                     }];
}

@end




