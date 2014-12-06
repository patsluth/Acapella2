

//
//  test.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-02.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "test.h"
#import "libsw/sluthwareios/sluthwareios.h"

@implementation test

- (id)init{
    self = [super init];
    if (self){
        self.backgroundColor = [UIColor yellowColor];
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0001, 0.0001);
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animate) userInfo:nil repeats:NO];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor purpleColor];
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0001, 0.0001);
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animate) userInfo:nil repeats:NO];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //self.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animate) userInfo:nil repeats:NO];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)animate
{
    [self animateTo];
}

- (void)animateTo
{
    UIView *sub;
    
    for (UIView *view in self.subviews){
        sub = view;
    }
    
    [UIView animateWithDuration:8
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 5.0, 5.0);
                         if (sub){
                             sub.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 5);
                         }
    }completion:^(BOOL finished){
        [UIView animateWithDuration:8
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0001, 0.0001);
                             if (sub){
                                 sub.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
                             }
                         }completion:^(BOOL finished){
                             [self animateTo];
                         }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
