//
//  SWAcapellaBase.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAcapellaBase2.h"

@class SWAcapellaActionIndicatorController;

@interface SWAcapellaBase : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) id delegateAcapella;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIScrollView *scrollview;
@property (readonly, strong, nonatomic) SWAcapellaActionIndicatorController *actionIndicatorController;

- (void)resetContentOffset;
- (void)finishWrapAroundAnimation;
- (void)stopWrapAroundFallback;

@end




