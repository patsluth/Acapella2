//
//  SWAcapellaBase2.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "sluthwareios.h"

@class SWAcapellaTableView;
@class SWAcapellaScrollView;

@protocol SWAcapellaDelegate <NSObject>

@required
- (void)swAcapellaOnTap:(CGPoint)percentage;
- (void)swAcapellaOnSwipe:(SW_SCROLL_DIRECTION)direction;
- (void)swAcapellaOnLongPress:(CGPoint)percentage;

@end





@interface SWAcapellaBase2 : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) id <SWAcapellaDelegate> delegateAcapella;

@property (strong, nonatomic) SWAcapellaTableView *tableView;
@property (strong, nonatomic) SWAcapellaScrollView *scrollview;
//@property (readonly, strong, nonatomic) SWAcapellaActionIndicatorController *actionIndicatorController;




@end




