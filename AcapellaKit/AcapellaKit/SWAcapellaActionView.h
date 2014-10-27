//
//  SWAcapellaActionView.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWAcapellaActionView : UIView

@property (readonly, strong, nonatomic) NSString *actionItemIdentifier;
@property (readonly, nonatomic) CGFloat displayTime;

- (id)initWithActionItemIdentifier:(NSString *)identifier andDisplayTime:(CGFloat)time;

@end
