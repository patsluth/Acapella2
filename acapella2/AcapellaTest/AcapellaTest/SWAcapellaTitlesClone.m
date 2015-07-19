//
//  SWAcapellaTitlesClone.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2015-07-18.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTitlesClone.h"





@implementation SWAcapellaTitlesClone

- (void)drawRect:(CGRect)rect
{
    if (self.titles){
        CGFloat originalOpacity = self.titles.layer.opacity;
        self.titles.layer.opacity = 1.0;
        [self.titles.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.titles.layer.opacity = originalOpacity;
    }
}

@end




