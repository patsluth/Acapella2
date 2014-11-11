//
//  SWAcapellaBase.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SWAcapellaScrollViewProtocol.h"
#import "libsw/sluthwareios/sluthwareios.h"

@class SWAcapellaBase;
@class SWAcapellaTableView;
@class SWAcapellaScrollView;

@protocol SWAcapellaDelegate <NSObject>

@required
- (void)swAcapella:(SWAcapellaBase *)view onTap:(CGPoint)percentage;
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction;
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(CGPoint)percentage;

@end





@interface SWAcapellaBase : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) id <SWAcapellaDelegate> delegateAcapella;

@property (strong, nonatomic) SWAcapellaTableView *tableview;
@property (strong, nonatomic) SWAcapellaScrollView *scrollview;

@property (readwrite, nonatomic) CGFloat acapellaTopAccessoryHeight;
@property (readwrite, nonatomic) CGFloat acapellaBottomAccessoryHeight;

@end




