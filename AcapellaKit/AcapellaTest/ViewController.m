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
