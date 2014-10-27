//
//  SWAcapellaActionView.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaActionView.h"

@interface SWAcapellaActionView()
{
}

@property (readwrite, strong, nonatomic) NSString *actionItemIdentifier;
@property (readwrite, nonatomic) CGFloat displayTime;

@end

@implementation SWAcapellaActionView

- (id)initWithActionItemIdentifier:(NSString *)identifier andDisplayTime:(CGFloat)time
{
    self = [super init];
    
    if (self){
        self.actionItemIdentifier = identifier;
        self.displayTime = time;
    }
    
    return self;
}

@end
