//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "libsw/sluthwareios/sluthwareios.h"
#import "test.h"
#import <objc/objc.h>

@interface ViewController ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) SWAcapellaBase *acapella;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = CGRectMake(0, 100, 0, 0);
    [self.view addSubview:self.contentView];
    
    self.acapella = [[SWAcapellaBase alloc] init];
    self.acapella.delegateAcapella = self;
    [self.contentView addSubview:self.acapella];
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(resizeB) userInfo:nil repeats:NO];
    
    test *tester = [[test alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    [self.view addSubview:tester];
    [self.view bringSubviewToFront:self.contentView];
}

- (void)resizeA
{
    self.contentView.frame = CGRectMake(40, 100, self.view.frame.size.width - 80, 500);
}

- (void)resizeB
{
    self.contentView.frame = CGRectMake(0, 100, self.view.frame.size.width, 200);
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                      block:^{
                                          //self.acapella.acapellaTopAccessoryHeight = 200;
    }repeats:NO];
}

#pragma mark SWAcapellaDelegate

- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
    if (tap.state == UIGestureRecognizerStateEnded){
    }
}

- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    if (direction != SW_SCROLL_DIR_NONE){
        
        if (direction == SW_SCROLL_DIR_UP){
            
            [view stopWrapAroundFallback];
            
            [[[SWUIAlertView alloc] initWithTitle:@"a"
                                         message:@"B"
                              clickedButtonBlock:^(UIAlertView *uiAlert, NSInteger buttonIndex){
                                  
                              }
                                 didDismissBlock:^(UIAlertView *uiAlert, NSInteger buttonIndex){
                                     [view finishWrapAroundAnimation];
                                 }
                               cancelButtonTitle:@"P"
                                otherButtonTitles:nil] show];
        } else if (direction == SW_SCROLL_DIR_LEFT) {
            
            [view finishWrapAroundAnimation];
            
        } else {
            [view finishWrapAroundAnimation];
            [view finishWrapAroundAnimation];
            [view finishWrapAroundAnimation];
        }
        
        if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
            [view stopWrapAroundFallback];
            [view finishWrapAroundAnimation];
            [view finishWrapAroundAnimation];
            [view finishWrapAroundAnimation];
        }
    }
}

- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
    if (longPress.state == UIGestureRecognizerStateBegan){
        
    } else if (longPress.state == UIGestureRecognizerStateEnded){
        
    }
}

- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
