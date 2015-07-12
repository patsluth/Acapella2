//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "libsw/libSluthware/NSTimer+SW.h"

@import Social;
@import Foundation;





@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *button;

@end





@implementation ViewController

- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForOwner:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.acapella){
        [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view preInitializeAction:^(SWAcapella *a){
            a.owner = self;
            a.titles = self.dragView;
            a.topSlider = self.top;
            a.bottomSlider = self.bottom;
        }] ForOwner:self];
    }
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

- (IBAction)buttonClick:(id)sender
{
//    CATransform3D newTransform = self.button.layer.transform;
//    newTransform = CATransform3DScale(newTransform, 0.9, 0.9, 1.0);
    
    
}

@end




