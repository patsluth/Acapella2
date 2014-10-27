//
//  ViewController.m
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "sluthwareios.h"

@interface ViewController ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) SWAcapellaBase *acapella;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.frame = CGRectMake(0, 400, 0, 0);
    [self.view addSubview:self.contentView];
    
    self.acapella = [[SWAcapellaBase alloc] init];
    self.acapella.delegateAcapella = self;
    [self.contentView addSubview:self.acapella];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resizeA) userInfo:nil repeats:NO];
}

- (void)resizeA
{
    [self.contentView setSize:CGSizeMake(self.view.frame.size.width, 150)];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(resizeB) userInfo:nil repeats:NO];
}

- (void)resizeB
{
    self.contentView.frame = CGRectMake(40, 200, self.view.frame.size.width - 80, 300);
}

#pragma mark SWAcapellaDelegate

- (void)swAcapellaOnTap:(CGPoint)percentage
{
    //NSLog(@"Acapella On Tap %@", NSStringFromCGPoint(percentage));
    
    SWAcapellaActionView *songSkip = [self.acapella.actionIndicator actionViewForIdentifier:@"songskip"];
    
    if (!songSkip){
        songSkip = [[SWAcapellaActionView alloc] initWithActionItemIdentifier:[NSString
                                                                               stringWithFormat:@"%d", arc4random()]
                                                               andDisplayTime:2.0];
        songSkip.backgroundColor = [UIColor redColor];
        UILabel *text = [[UILabel alloc] init];
        text.text = songSkip.actionItemIdentifier;
        [text sizeToFit];
        [songSkip addSubview:text];
    }
    
    [self.acapella.actionIndicator addViewToActionQueue:songSkip];
    
    
}

- (void)swAcapellaOnSwipe:(SW_SCROLL_DIRECTION)direction
{
    //NSLog(@"Acapella On Swipe %u", direction);
    
    if (direction != SW_DIRECTION_NONE){
        [self.acapella finishWrapAroundAnimation];
    }
}

- (void)swAcapellaOnLongPress:(CGPoint)percentage
{
    //NSLog(@"Acapella On Long Press %@", NSStringFromCGPoint(percentage));
}

@end
