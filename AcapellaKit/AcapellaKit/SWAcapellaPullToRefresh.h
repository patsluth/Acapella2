//
//  SWAcapellaPullToRefresh.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-12-17.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWAcapellaScrollingViewProtocol.h"





@interface SWAcapellaPullToRefresh : UIControl <UIScrollViewDelegate>

@property (readonly, nonatomic) SWScrollDirection direction;

@end




