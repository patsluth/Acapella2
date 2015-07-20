//
//  SWAcapellaTitlesClone.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2015-07-18.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTitlesClone.h"





@interface SWAcapellaTitlesClone()

@property (strong, nonatomic) CADisplayLink *displayLink;

@end





@implementation SWAcapellaTitlesClone

//- (void)setTitles:(UIView *)titles
//{
//    _titles = titles;
//    
//    [NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
//    [self setNeedsDisplay];
//}

- (void)startDisplayLink
{
//    if (!self.displayLink){
//        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkUpdate)];
//        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    }
}

- (void)stopDisplayLink
{
//    if (self.displayLink){
//        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    }
//    
//    self.displayLink = nil;
}

- (void)displayLinkUpdate
{
    //wait for the next iteration
    //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    [self setNeedsDisplay];
}

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




