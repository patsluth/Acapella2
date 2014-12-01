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
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface ViewController ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) SWAcapellaBase *acapella;

@property (strong, nonatomic) UITableView *tableview;
@property (strong, nonatomic) UIImageView *stretchableTableViewHeader;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.tableview = [[UITableView alloc] init];
//    self.tableview.backgroundColor = [UIColor clearColor];
//    
//    self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [self.view addSubview:self.tableview];
//    
//    self.tableview.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
//    self.tableview.delegate = self;
//    self.tableview.dataSource = self;
//
//    self.tableview.showsHorizontalScrollIndicator = YES;
//    self.tableview.showsVerticalScrollIndicator = YES;
//    
//    
//    
//    
//    UIView *tableViewHeader = [[UIView alloc] init];
//    tableViewHeader.backgroundColor = [UIColor clearColor];
//    tableViewHeader.frame = CGRectMake(0, 0, self.tableview.frame.size.width, [UIImage imageNamed:@"banner"].size.height / 2);
//    self.tableview.tableHeaderView = tableViewHeader;
//    
//    self.stretchableTableViewHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner"]];
//    self.stretchableTableViewHeader.backgroundColor = [UIColor blueColor];
//    self.stretchableTableViewHeader.contentMode = UIViewContentModeScaleAspectFill;
//    self.stretchableTableViewHeader.frame = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, [UIImage imageNamed:@"banner"].size.height / 2);
//    [self.view addSubview:self.stretchableTableViewHeader];
//    
//    [self.view bringSubviewToFront:self.tableview];
//    
//    
//    return;
    
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

















#pragma mark Table View Tests

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat delta = 0.0f;
    CGRect rect = CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, [UIImage imageNamed:@"banner"].size.height / 2);
    
    delta = fabs(MIN(0.0f, self.tableview.contentOffset.y));
    
    if (self.tableview.contentOffset.y > 0.0f){
        rect.origin.y -= self.tableview.contentOffset.y;
    }
    
    rect.size.height += delta;
    
    self.stretchableTableViewHeader.frame = rect;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"pat";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        //cell.alpha = 0.1;
    }
    
    [cell setSelected:YES];
    
    return cell;
}

@end
