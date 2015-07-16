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
@property (strong, nonatomic) UIView *testView;

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
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 50)];
    self.testView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.testView];
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
    UIView *titlesCopy = [self.testView resizableSnapshotViewFromRect:self.testView.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    titlesCopy.center = CGPointZero;
    
    [self.view addSubview:titlesCopy];
    
    
    
   // [self.view drawViewHierarchyInRect:CGRectMake(0, 0, 100, 100) afterScreenUpdates:YES];
    
    
    
    
    
    //self.dragView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
    //self.dragView.layer.opacity = 0.0;
    
    //UIView *temp = [self.button snapshotViewAfterScreenUpdates:YES];
    //self.button.hidden = YES;
    //[self.view addSubview:temp];
    //temp.frame = CGRectMake(0, 0, temp.frame.size.width, temp.frame.size.height);
}

@end




