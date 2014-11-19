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
- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage;
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction;
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage;

@optional
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end





@interface SWAcapellaBase : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) id <SWAcapellaDelegate> delegateAcapella;

@property (strong, nonatomic) SWAcapellaTableView *tableview;
@property (strong, nonatomic) SWAcapellaScrollView *scrollview;

@property (readwrite, nonatomic) CGFloat acapellaTopAccessoryHeight;
@property (readwrite, nonatomic) CGFloat acapellaBottomAccessoryHeight;

@end




