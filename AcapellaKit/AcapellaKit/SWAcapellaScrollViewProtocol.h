//
//  SWAcapellaScrollViewProtocol.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-09.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SWAcapellaScrollViewProtocol <NSObject>

@required
- (void)resetContentOffset:(BOOL)animated;
- (void)finishWrapAroundAnimation;
- (void)startWrapAroundFallback;
- (void)stopWrapAroundFallback;

@optional
- (CGPoint)defaultContentOffset;
- (NSIndexPath *)defaultIndexPath;

@optional

@end




