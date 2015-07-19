//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "libsw/libSluthware/NSTimer+SW.h"

@import CoreGraphics;
@import Social;
@import Foundation;





@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@end





@implementation ViewController

- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    
    
    
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
//    [self.view addGestureRecognizer:tap];
    
    
    
    
    
    
    if (!self.acapella){
        
        [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                      preInitializeAction:^(SWAcapella *a){
                                                          a.owner = self;
                                                          a.titles = self.dragView;
                                                      }]
                      ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN];
        
    }
    
    [NSTimer scheduledTimerWithTimeInterval:10 block:^{
        
        
        for (UIView *v in self.dragView.subviews){
            if ([v isKindOfClass:[UILabel class]]){
                UILabel *l = (UILabel *)v;
                l.text = [NSString stringWithFormat:@"%d", rand()];
                [l sizeToFit];
            }
        }
        
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]){
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
        
        
    }repeats:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        if (pan == self.acapella.pan){
            CGPoint panVelocity = [pan velocityInView:pan.view];
            
            if (fabs(panVelocity.y) > fabs(panVelocity.x)){
                return NO;
            }
        }
        
    }
    
    return YES;
}

- (void)onTap:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:tap.view];
    
    [self.animator removeAllBehaviors];
    
    UIDynamicItemBehavior *b = [[UIDynamicItemBehavior alloc] initWithItems:@[self.button]];
    b.resistance = 1;
    b.elasticity = 0;
    b.density = 10000;
    b.friction = 1000;
    
    [self.animator addBehavior:b];
    
    UISnapBehavior *s = [[UISnapBehavior alloc] initWithItem:self.button snapToPoint:location];
    s.damping = 1.0;
    [self.animator addBehavior:s];
    
}

- (IBAction)buttonClick:(id)sender
{
}

@end




