//
//  SWAcapellaScrollView.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-08.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface SWAcapellaScrollView : UIScrollView

@property (readwrite, nonatomic) BOOL isAnimating;

@property (readonly, nonatomic) CGPoint defaultContentOffset;

- (void)resetContentOffset:(BOOL)animated;
- (void)finishWrapAroundAnimation;
- (void)startWrapAroundFallback;
- (void)stopWrapAroundFallback;

@end




