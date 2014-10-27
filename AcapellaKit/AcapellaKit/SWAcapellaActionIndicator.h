//
//  SWAcapellaActionIndicator.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWAcapellaActionView;

@interface SWAcapellaActionIndicator : UIView

- (void)addViewToActionQueue:(SWAcapellaActionView *)view;
- (SWAcapellaActionView *)actionViewForIdentifier:(NSString *)identifier;

@end




