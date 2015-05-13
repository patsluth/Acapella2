//
//  SWAcapellaScrollView.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWAcapellaScrollingViewProtocol.h"





@interface SWAcapellaScrollView : UIScrollView <SWAcapellaScrollingViewProtocol>

@property (readwrite, nonatomic) BOOL isAnimating;

@property (readonly, nonatomic) CGPoint defaultContentOffset;
@property (readwrite, nonatomic) CGPoint previousContentOffset;

@property (readwrite, nonatomic) SWScrollDirection currentScrollDirection;

- (void)resetContentOffset:(BOOL)animated;
- (void)finishWrapAroundAnimation;
- (void)startWrapAroundFallback;
- (void)stopWrapAroundFallback;

@end




