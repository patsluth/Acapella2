//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "SWAcapellaTitlesCloneContainer.h"
#import "libsw/libSluthware/NSTimer+SW.h"

#import <CoreFoundation/CoreFoundation.h>


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
    
    
    
    
    if (!self.acapella){
        
        [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                      preInitializeAction:^(SWAcapella *a){
                                                          a.owner = self;
                                                          a.titles = self.dragView;
                                                      }]
                      ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN];
        
        
        
        [self.view addGestureRecognizer:self.acapella.tap];
        
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
   // if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        
//        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
//        
//        if (pan == self.acapella.pan){
//            CGPoint panVelocity = [pan velocityInView:pan.view];
//            
////            if (fabs(panVelocity.y) > fabs(panVelocity.x)){
////                return NO;
////            }
//        }
//    }
    
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.acapella.tap == gestureRecognizer){
        return ![touch.view isKindOfClass:[UISlider class]];
    }
    
    return YES;
}

- (void)onTap:(UITapGestureRecognizer *)tap
{
    
    CGPoint location = [tap locationInView:tap.view];
    
    [self.animator removeAllBehaviors];
    
    UIDynamicItemBehavior *b = [[UIDynamicItemBehavior alloc] initWithItems:@[self.button]];
    
    [self.animator addBehavior:b];
    
    UISnapBehavior *s = [[UISnapBehavior alloc] initWithItem:self.button snapToPoint:location];
    [self.animator addBehavior:s];
    
}

- (IBAction)buttonClick:(id)sender
{
    [NSTimer scheduledTimerWithTimeInterval:2 block:^{
        for (UILabel *l in self.dragView.subviews){
            l.text = [NSString stringWithFormat:@"%d", rand()];
        }
        [self.acapella.titlesCloneContainer setNeedsDisplay];
    }repeats:YES];
}

@end




