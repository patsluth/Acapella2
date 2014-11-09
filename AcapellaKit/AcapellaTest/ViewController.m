//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "sluthwareios.h"
#import "test.h"

@interface ViewController ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) SWAcapellaBase2 *acapella;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = CGRectMake(0, 100, 0, 0);
    [self.view addSubview:self.contentView];
    
    self.acapella = [[SWAcapellaBase2 alloc] init];
    self.acapella.delegateAcapella = self;
    [self.contentView addSubview:self.acapella];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resizeB) userInfo:nil repeats:NO];
    
    test *tester = [[test alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    [self.view addSubview:tester];
    [self.view bringSubviewToFront:self.contentView];
}

- (void)resizeA
{
    self.contentView.frame = CGRectMake(40, 200, self.view.frame.size.width - 80, 300);
    //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resizeB) userInfo:nil repeats:NO];
}

- (void)resizeB
{
    self.contentView.frame = CGRectMake(0, 100, self.view.frame.size.width, 100);
}

#pragma mark SWAcapellaDelegate

- (void)swAcapellaOnTap:(CGPoint)percentage
{
    NSLog(@"Acapella On Tap %@", NSStringFromCGPoint(percentage));
}

- (void)swAcapellaOnSwipe:(SW_SCROLL_DIRECTION)direction
{
    //NSLog(@"Acapella On Swipe %u", direction);
    
    if (direction != SW_SCROLL_DIR_NONE){
        
        if (direction == SW_SCROLL_DIR_UP){
            
            [self.acapella.scrollview stopWrapAroundFallback];
            
            [[[SWUIAlertView alloc] initWithTitle:@"a"
                                         message:@"B"
                              clickedButtonBlock:^(UIAlertView *uiAlert, NSInteger buttonIndex){
                                  
                              }
                                 didDismissBlock:^(UIAlertView *uiAlert, NSInteger buttonIndex){
                                     [self.acapella.scrollview finishWrapAroundAnimation];
                                 }
                               cancelButtonTitle:@"P"
                                otherButtonTitles:nil] show];
        } else {
            
            [self.acapella.scrollview finishWrapAroundAnimation];
            
        }
        
        
        
        
        
        
        
        if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
            
            /*
            SWAcapellaActionIndicator *songSkip = [self.acapella.actionIndicatorController
                                                   actionIndicatorWithIdentifierIfExists:@"songskip"];
            
            if (!songSkip){
                songSkip = [[SWAcapellaActionIndicator alloc] initWithFrame:CGRectMake(0,
                                                                                       0,
                                                                                       100,
                                                                                       self.acapella.actionIndicatorController.frame.size.height)
                                               andActionIndicatorIdentifier:@"songskip"];
                songSkip.backgroundColor = [UIColor purpleColor];
                songSkip.actionIndicatorDisplayTime = 5.0;
                
                UILabel *text = [[UILabel alloc] init];
                text.layer.anchorPoint = CGPointMake(0.5, 0.5);
                text.textAlignment = NSTextAlignmentCenter;
                text.text = @"--->";
                text.textColor = [UIColor whiteColor];
                [text sizeToFit];
                [songSkip addSubview:text];
                [text setCenter:CGPointMake(songSkip.frame.size.width / 2, songSkip.frame.size.height / 2)];
            }
            
            UILabel *lab;
            
            for (UILabel *view in songSkip.subviews){
                lab = view;
            }
            
            if (lab){
                void (^_applyRotation)(CGAffineTransform tran) = ^(CGAffineTransform tran){
                    lab.transform = tran;
                };
                
                BOOL animated = songSkip.isShowing || songSkip.isAnimatingToHide;
                
                if (animated && direction == SW_DIRECTION_LEFT && !lab.layer.animationKeys){
                    //we need to set this initially so we will rotate counterclockwise from right to left
                    _applyRotation(CGAffineTransformMakeRotation(SWDegreesToRadians(-0.001)));
                }
                
                CGFloat animationTime = 0.0;
                
                if (songSkip.isShowing){
                    animationTime = songSkip.actionIndicatorDisplayTime * 0.75; //animate to 75% of the display time, since the timer will be restarted and the view will display for that amount of time
                //should never hit because of animationToShow, but just in case
                } else if (songSkip.isAnimatingToHide || songSkip.isAnimatingToShow){
                    //it will take this ammount of time for the animation to reshow from its current state, so they will be syncronized
                    animationTime = songSkip.actionIndicatorAnimationInTime;
                }
                
                [UIView animateWithDuration:(animated) ? animationTime : 0.0
                                      delay:0.0
                                    options:(UIViewAnimationOptionBeginFromCurrentState |
                                             UIViewAnimationOptionAllowUserInteraction |
                                             UIViewAnimationOptionCurveEaseInOut)
                                 animations:^{
                                     
                                     CGFloat deg = (direction == SW_DIRECTION_LEFT) ? 180.0 : 0.0;
                                     _applyRotation(CGAffineTransformMakeRotation(SWDegreesToRadians(deg)));
                                     
                                 }
                                 completion:nil];
            }
            
            [self.acapella.actionIndicatorController addActionIndicatorToQueue:songSkip];
             */
        }
    }
}

- (void)swAcapellaOnLongPress:(CGPoint)percentage
{
    //NSLog(@"Acapella On Long Press %@", NSStringFromCGPoint(percentage));
}

@end
