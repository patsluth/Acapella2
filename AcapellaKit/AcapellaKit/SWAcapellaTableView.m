//
//  SWAcapellaTableView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTableView.h"

@implementation SWAcapellaTableView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (self.numberOfSections == 1 && [self numberOfRowsInSection:0] > 3){
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] //row for our main acapella view
                    atScrollPosition:UITableViewScrollPositionMiddle
                            animated:NO];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end




