//
//  SWAcapellaTitlesClone.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2015-07-18.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTitlesClone.h"





@interface SWAcapellaTitlesClone()

@end





@implementation SWAcapellaTitlesClone

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self){
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)setTitles:(UIView *)titles
{
    _titles = titles;
    
    if (_titles){
        self.frame = _titles.frame;
    } else {
        self.frame = CGRectZero;
    }
    
    [self setNeedsDisplay];
    //wait for the next iteration, so we know the original text has been updated
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    [self setNeedsDisplay];
}

//- (void)setNeedsDisplay
//{
//    [super setNeedsDisplay];
//    
//    CGFloat xxxxx = CACurrentMediaTime();
//    
//    
//    
//    
//    for (UIView *v in self.subviews){
//        [v removeFromSuperview];
//    }
//    
//    
//    
//    //CALayer *layer = [self.titles.layer presentationLayer];
//    //layer.opacity = 1.0;
//    //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:1 sinceDate:[NSDate date]]];
//    
//    
//    
//    NSData *tempArchiveView = [NSKeyedArchiver archivedDataWithRootObject:self.titles];
//    UIView *viewOfSelf = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchiveView];
//    
//    
//    //UIView *x = [self.titles snapshotViewAfterScreenUpdates:NO];
//    //x.layer.opacity = 1.0;
//   // NSLog(@"PAT %@", NSStringFromCGRect(x.frame));
//    [self addSubview:viewOfSelf];
//    viewOfSelf.frame = viewOfSelf.bounds;
//    viewOfSelf.layer.opacity = 1.0;
//    
//    //layer.opacity = 0.0;
//    
//    NSLog(@"UPDATING SNAPSHOT %f", CACurrentMediaTime() - xxxxx);
//    
//}

#pragma mark Rendering

- (void)drawRect:(CGRect)rect
{
    if (self.titles){
        
        CALayer *layer = [self.titles.layer presentationLayer];
        
        if (!layer){
            layer = self.titles.layer;
        }
        
        CGFloat originalOpacity = layer.opacity;
        layer.opacity = 1.0;
        
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);
        [layer renderInContext:UIGraphicsGetCurrentContext()];
        
        layer.opacity = originalOpacity;
    }
}


@end




