//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "NSTimer+SW.h"

@import Social;
@import Foundation;

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *acapellaContainer;
@property (strong, nonatomic) SWAcapellaBase *acapella;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.acapella){}
    
    
    
    //[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(resizeB) userInfo:nil repeats:NO];
}

- (void)resizeA
{
    self.acapellaContainer.frame = CGRectMake(40, 100, self.view.frame.size.width - 80, 200);
    [self.acapellaContainer layoutIfNeeded];
}

- (void)resizeB
{
    self.acapellaContainer.frame = CGRectMake(0, 100, self.view.frame.size.width, 100);
    [self.acapellaContainer layoutIfNeeded];
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                      block:^{
                                          [self resizeA];
    }repeats:NO];
}

#pragma mark - SWAcapellaDelegate

- (void)swAcapella:(SWAcapellaBase *)swAcapella onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
    if (tap.state == UIGestureRecognizerStateEnded) {
    }
}

- (void)swAcapella:(id<SWAcapellaScrollingViewProtocol>)swAcapella onSwipe:(SWScrollDirection)direction
{
    if (swAcapella == self.acapella.scrollview){
        [self.acapella.scrollview stopWrapAroundFallback];
        [self.acapella.scrollview finishWrapAroundAnimation];
        [self.acapella.scrollview finishWrapAroundAnimation];
        [self.acapella.scrollview finishWrapAroundAnimation];
    } else if (swAcapella == self.acapella.tableview){
        [self.acapella.tableview resetContentOffset:YES];
    }
    
}

- (void)swAcapella:(SWAcapellaBase *)swAcapella onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
    } else if (longPress.state == UIGestureRecognizerStateEnded) {

    }
}

#pragma mark - Internal

- (SWAcapellaBase *)acapella
{
    if (!_acapella){
        
        _acapella = [[SWAcapellaBase alloc] init];
        _acapella.delegate = self;
        
        [self.acapellaContainer addSubview:_acapella];
        
        [self.acapellaContainer addConstraint:[NSLayoutConstraint constraintWithItem:_acapella
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.acapellaContainer
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self.acapellaContainer addConstraint:[NSLayoutConstraint constraintWithItem:_acapella
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.acapellaContainer
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self.acapellaContainer addConstraint:[NSLayoutConstraint constraintWithItem:_acapella
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.acapellaContainer
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self.acapellaContainer addConstraint:[NSLayoutConstraint constraintWithItem:_acapella
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.acapellaContainer
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self.acapellaContainer layoutIfNeeded];
        [self.acapella layoutIfNeeded];
        
    }
    
    return _acapella;
}

@end




