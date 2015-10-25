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
                                                          a.prefKeyPrefix = @"pat";
                                                          a.prefApplication = @"com.apple.Music";
                                                      }]
                      ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN];
        
    }
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




