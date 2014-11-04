//
//  SWAcapellaActionIndicatorController.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-28.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaActionIndicator.h"

@class SWAcapellaBase;

@interface SWAcapellaActionIndicatorController : UIView <SWAcapellaActionIndicatorDelegate>

- (void)addActionIndicatorToQueue:(SWAcapellaActionIndicator *)view;
- (SWAcapellaActionIndicator *)actionIndicatorWithIdentifierIfExists:(NSString *)identifier;

@end




