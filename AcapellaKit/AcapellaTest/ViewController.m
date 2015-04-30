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
        
        
      
        
        
        
        
        
        
        if (NSClassFromString(@"UIAlertController")){
            
            UIAlertController *c = [UIAlertController alertControllerWithTitle:@"Share" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                NSLog(@"%@", action);
            }];
            
            [c addAction:cancel];
            
            
            UIAlertActionStyle hasTwitter = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive;
            
            UIAlertAction *tweet = [UIAlertAction actionWithTitle:@"twitter" style:hasTwitter handler:^(UIAlertAction *action) {
                SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                
                compose.completionHandler = ^(SLComposeViewControllerResult result) {
                    NSLog(@"PAT");
                };
                
                [self presentViewController:compose animated:YES completion:nil];
            }];
            
            [c addAction:tweet];
            
            
            
            UIAlertActionStyle hasFacebook = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive;
            
            UIAlertAction *facebook = [UIAlertAction actionWithTitle:@"facebook" style:hasFacebook handler:^(UIAlertAction *action) {
                SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [self presentViewController:compose animated:YES completion:nil];
            }];
            
            [c addAction:facebook];
            
            [self presentViewController:c animated:YES completion:nil];
            
        }
        
    }
}

- (void)swAcapella:(SWAcapellaScrollView *)swAcapella onSwipe:(ScrollDirection)direction
{
    [swAcapella stopWrapAroundFallback];
    [swAcapella finishWrapAroundAnimation];
    [swAcapella finishWrapAroundAnimation];
    [swAcapella finishWrapAroundAnimation];
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




