//
//  UISnapBehaviorHorizontal.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "UISnapBehaviorHorizontal.h"





@interface UISnapBehaviorHorizontal()
{
}

@property (readwrite, nonatomic) CGFloat centerYLock;

@end





@implementation UISnapBehaviorHorizontal

- (id)initWithItem:(id<UIDynamicItem>)item snapToPoint:(CGPoint)point
{
    self = [super initWithItem:item snapToPoint:point];
    
    if (self){
        
        self.centerYLock = item.center.y;
        
        __weak typeof(self) weakSelf = self;
        
        self.action = ^{
            item.center = CGPointMake(item.center.x, weakSelf.centerYLock);
        };
    }
    
    return self;
}

@end




