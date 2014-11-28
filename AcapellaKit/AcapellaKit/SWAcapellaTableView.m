//
//  SWAcapellaTableView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTableView.h"
#import "libsw/sluthwareios/sluthwareios.h"

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
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.bounces = NO;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        
        self.scrollsToTop = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
#ifdef DEBUG
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        
        self.separatorColor = [UIColor blackColor];
        self.separatorStyle = UITableViewCellSelectionStyleDefault;
#endif
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

- (void)reloadData
{
    [super reloadData];
    
    [self resetContentOffset:NO];
}

#pragma mark SWAcapellaScrollViewProtocol

- (CGPoint)defaultContentOffset
{
    CGRect mainRect = [self rectForRowAtIndexPath:[self defaultIndexPath]];
    return mainRect.origin;
}

- (NSIndexPath *)defaultIndexPath;
{
    return [NSIndexPath indexPathForRow:2 inSection:0];
}

- (void)resetContentOffset:(BOOL)animated
{
    //reset
    self.currentVelocity = CGPointZero;
    self.userInteractionEnabled = YES;
    
    if (self.numberOfSections == 1 && [self numberOfRowsInSection:0] > 3){
        
        [self scrollToRowAtIndexPath:[self defaultIndexPath]
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
    
    [self resetContentOffset:YES];
}

@end




