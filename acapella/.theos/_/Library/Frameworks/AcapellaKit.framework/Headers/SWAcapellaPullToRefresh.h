//
//  SWAcapellaPullToRefresh.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-12-17.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE 0.20

@interface SWAcapellaPullToRefresh : UIControl <UIScrollViewDelegate>

//0 = none
//1 = top
//2 = bottom
@property (readonly, nonatomic) NSInteger swaState;

- (void)setImage:(UIImage *)image;

@end




