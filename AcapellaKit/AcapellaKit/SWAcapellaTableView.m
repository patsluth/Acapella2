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
        
        self.bounces = YES;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = YES;
        
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
    return [NSIndexPath indexPathForRow:1 inSection:0];
}

- (void)resetContentOffset:(BOOL)animated
{
    if (self.isTracking){
        return;
    }
    
    //reset
    self.currentVelocity = CGPointZero;
    self.userInteractionEnabled = YES;
    
    if (self.numberOfSections == 1 && [self numberOfRowsInSection:0] > [self defaultIndexPath].row){
        
        [self scrollToRowAtIndexPath:[self defaultIndexPath]
                    atScrollPosition:UITableViewScrollPositionMiddle
                            animated:animated];
        
    }
}

@end




