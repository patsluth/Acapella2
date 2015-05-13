//
//  SWAcapellaTableView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-05-06.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTableView.h"





@interface SWAcapellaTableView()
{
}

@end





@implementation SWAcapellaTableView

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self) {
        
        self.clipsToBounds = YES;
        self.scrollsToTop = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.bounces = YES;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = YES;
        
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

- (void)reloadData
{
    [super reloadData];
    
    [self resetContentOffset:NO];
}

#pragma mark - Public

- (CGPoint)defaultContentOffset
{
    CGRect mainRect = [self rectForRowAtIndexPath:self.defaultIndexPath];
    return mainRect.origin;
}

- (NSIndexPath *)defaultIndexPath
{
    return [NSIndexPath indexPathForRow:1 inSection:0];
}

- (void)resetContentOffset:(BOOL)animated
{
    if (![NSThread isMainThread]){
        [self performSelectorOnMainThread:@selector(resetContentOffset:) withObject:@(animated) waitUntilDone:NO];
        return;
    }
    
    if (self.isTracking){
        return;
    }
    
    //reset
    self.userInteractionEnabled = YES;
    
    if (self.numberOfSections == 1 && [self numberOfRowsInSection:0] > [self defaultIndexPath].row){
        
        [self scrollToRowAtIndexPath:self.defaultIndexPath
                    atScrollPosition:UITableViewScrollPositionMiddle
                            animated:animated];
        
    }
}

@end




