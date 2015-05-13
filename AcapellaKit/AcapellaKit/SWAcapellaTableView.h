//
//  SWAcapellaTableView.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-05-06.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWAcapellaScrollingViewProtocol.h"





@interface SWAcapellaTableView : UITableView <SWAcapellaScrollingViewProtocol>

@property (readonly, nonatomic) CGPoint defaultContentOffset;
@property (readwrite, nonatomic) CGPoint previousContentOffset;
@property (readonly, nonatomic) NSIndexPath *defaultIndexPath;

@property (readwrite, nonatomic) SWScrollDirection currentScrollDirection;

- (void)resetContentOffset:(BOOL)animated;

@end




