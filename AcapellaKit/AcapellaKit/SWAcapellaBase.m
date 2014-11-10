//
//  SWAcapellaBase.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaBase.h"

#import "SWAcapellaScrollViewProtocol.h"
#import "SWAcapellaTableView.h"
#import "SWAcapellaScrollView.h"

@interface SWAcapellaBase()
{
}

//gesture recognizers
@property (strong, nonatomic) UITapGestureRecognizer *oneFingerTap;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@end

@implementation SWAcapellaBase

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.tableView = [[SWAcapellaTableView alloc] init];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.tableView];
        
        self.tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
#ifdef DEBUG
        self.backgroundColor = [UIColor redColor];
        self.tableView.backgroundColor = [UIColor orangeColor];
#endif
        
        [self initGestureRecognizers];
        
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(test) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)test
{
    
}

- (void)initGestureRecognizers
{
    [self resetGestureRecognizers];
    
    self.oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(onTap:)];
    self.oneFingerTap.cancelsTouchesInView = YES;
    [self addGestureRecognizer:self.oneFingerTap];
    
    
    
    
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                   action:@selector(onPress:)];
    self.longPress.minimumPressDuration = 0.7;
    [self addGestureRecognizer:self.longPress];
}

- (void)resetGestureRecognizers
{
    if (self.oneFingerTap){
        [self.oneFingerTap removeTarget:self action:@selector(onTap:)];
        [self removeGestureRecognizer:self.oneFingerTap];
        self.oneFingerTap = nil;
    }
    if (self.longPress){
        [self.longPress removeTarget:self action:@selector(onPress:)];
        [self removeGestureRecognizer:self.longPress];
        self.longPress = nil;
    }
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 5;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                return 200;
                break;
                
            case 1:
                return 40;
                break;
                
            case 2:
                return 100;
                break;
                
            case 3:
                return 40;
                break;
                
            case 4:
                return 200;
                break;
                
            default:
                break;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor blackColor];
        cell.alpha = 0.5;
        cell.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0){
            if (indexPath.row == 2){
                self.scrollview = [[SWAcapellaScrollView alloc] init];
                self.scrollview.delegate = self;
                self.scrollview.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                
                [cell.contentView addSubview:self.scrollview];
            }
        }
    }
    
    return cell;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                return @"swacapella_edge_of_the_world";
                break;
                
            case 1:
                return @"swacapella_accessory";
                break;
                
            case 2:
                return @"swacapella_main";
                break;
                
            case 3:
                return @"swacapella_accessory";
                break;
                
            case 4:
                return @"swacapella_edge_of_the_world";
                break;
                
            default:
                break;
        }
    }
    
    return @"default";
}

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= scrollView.previousScrollOffset.x &&
        scrollView.contentOffset.y == scrollView.previousScrollOffset.y){
        
        scrollView.currentScrollDirection = SW_SCROLL_DIR_LEFT;
        
    } else if (scrollView.contentOffset.x < scrollView.previousScrollOffset.x &&
               scrollView.contentOffset.y == scrollView.previousScrollOffset.y){
        
        scrollView.currentScrollDirection = SW_SCROLL_DIR_RIGHT;
        
    } else if (scrollView.contentOffset.x == scrollView.previousScrollOffset.x &&
               scrollView.contentOffset.y >= scrollView.previousScrollOffset.y){
        
        scrollView.currentScrollDirection = SW_SCROLL_DIR_UP;
        
    } else if (scrollView.contentOffset.x == scrollView.previousScrollOffset.x &&
               scrollView.contentOffset.y <= scrollView.previousScrollOffset.y){
        
        scrollView.currentScrollDirection = SW_SCROLL_DIR_DOWN;
        
    } else {
        
        scrollView.currentScrollDirection = SW_SCROLL_DIR_NONE;
        
    }
    
    scrollView.previousScrollOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    scrollView.currentVelocity = velocity;
    
    if (self.tableView == scrollView){
        
        if (fabs(velocity.y) > 0.3){
            return;
        }
        
        NSInteger directionModifier;
        
        if (self.tableView.currentScrollDirection == SW_SCROLL_DIR_DOWN){
            directionModifier = +1;
        } else if (self.tableView.currentScrollDirection == SW_SCROLL_DIR_UP){
            directionModifier = -1;
        } else {
            return;
        }
        
        NSIndexPath *targetIndexPath = [self.tableView indexPathForRowAtPoint:*targetContentOffset];
        
        if (targetIndexPath.section != 0){
            return;
        }
        
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
        
        
        if (targetIndexPath.row == 0){
            directionModifier = 1;
        } else if (targetIndexPath.row == numberOfRows - 1){
            directionModifier = -1;
        }
        
        
        CGFloat contentOffsetCenterY = self.tableView.contentOffset.y + (self.frame.size.height / 2);
        NSIndexPath *centredIndexPath;
        
        for (NSUInteger x = 0; x < numberOfRows; x++){
            CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:x inSection:0]];
            if (CGRectContainsPoint(rect, CGPointMake(rect.origin.x + (rect.size.width / 2), contentOffsetCenterY))){
                centredIndexPath = [NSIndexPath indexPathForRow:x inSection:0];
            }
        }
        
        CGRect centredIndexPathFrame = [self.tableView rectForRowAtIndexPath:centredIndexPath];
        
        switch (centredIndexPath.row) {
            case 0:
                *targetContentOffset = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].origin;
                break;
                
            case 1:
                *targetContentOffset = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].origin;
                break;
                
            case 2:
            {
                NSIndexPath *aboveCentredIndexPath = [NSIndexPath indexPathForRow:centredIndexPath.row - 1 inSection:0];
                NSIndexPath *belowCentredIndexPath = [NSIndexPath indexPathForRow:centredIndexPath.row + 1 inSection:0];
                CGRect aboveCentredIndexPathFrame = [self.tableView rectForRowAtIndexPath:aboveCentredIndexPath];
                CGRect belowCentredIndexPathFrame = [self.tableView rectForRowAtIndexPath:belowCentredIndexPath];
                
#ifdef DEBUG
                //NSLog(@"%ld==%ld", (long)aboveCentredIndexPath.row, (long)belowCentredIndexPath.row);
#endif
                
                //these two variables are so we can calucalate the percentage of the accessory view on screen
                CGFloat distToTopAccessory = self.tableView.contentOffset.y -
                (aboveCentredIndexPathFrame.origin.y + aboveCentredIndexPathFrame.size.height);
                CGFloat distToBottomAccessory = (self.tableView.contentOffset.y + centredIndexPathFrame.size.height) -
                (belowCentredIndexPathFrame.origin.y);
                
                if (distToTopAccessory < 0.0 && fabs(distToTopAccessory) > aboveCentredIndexPathFrame.size.height * 0.50){ //25%
                    
                    //move to top accessory
                    *targetContentOffset = aboveCentredIndexPathFrame.origin;
                    
                } else if (distToBottomAccessory > 0.0 && fabs(distToBottomAccessory) > belowCentredIndexPathFrame.size.height * 0.50){
                    
                    //move to bottom accessory
                    *targetContentOffset = CGPointMake(belowCentredIndexPathFrame.origin.x,
                                                       centredIndexPathFrame.origin.y + belowCentredIndexPathFrame.size.height);
                } else {
                    
                    //stay centered
                    *targetContentOffset = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].origin;
                    
                }
            }
                break;
                
            case 3:
            {
                CGRect mainCellFrame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                CGRect bottomAccessoryCellFrame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                *targetContentOffset = CGPointMake(mainCellFrame.origin.x,
                                                   mainCellFrame.origin.y + bottomAccessoryCellFrame.size.height);
            }
                break;
                
            case 4:
                *targetContentOffset = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]].origin;
                break;
                
            default:
                *targetContentOffset = centredIndexPathFrame.origin;
                break;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    if (self.scrollview == scrollView){
//        
//    } else if (self.tableView == scrollView){
//        
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = NO;
    
    if (self.scrollview == scrollView){
        
        SWPage page = [self.scrollview page];
        
        BOOL shouldAnimate = (page.x != [self.scrollview pageInCentre].x); //centered already
        
        if (shouldAnimate){
            
            SW_SCROLL_DIRECTION direction = SW_SCROLL_DIR_NONE;
            
            if (page.x == 0 && page.y == 0){
                direction = SW_SCROLL_DIR_RIGHT;
            } else if (page.x == 2 && page.y == 0) {
                direction = SW_SCROLL_DIR_LEFT;
            }
            
            [self.scrollview startWrapAroundFallback];
            
            if (self.delegateAcapella){
                [self.delegateAcapella swAcapella:self.scrollview onSwipe:direction];
            }
            
        } else {
            
            [self.scrollview resetContentOffset:NO];
            self.scrollview.userInteractionEnabled = YES;
            
        }
        
    } else if (self.tableView == scrollView){
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:self.tableView.contentOffset];
        
        if (indexPath.section == 0){
            
            if (indexPath.row == 0 || indexPath.row == [self.tableView numberOfRowsInSection:0] - 1){
                
                [self.scrollview startWrapAroundFallback];
                
                if (self.delegateAcapella){
                    [self.delegateAcapella swAcapella:self.tableView
                                              onSwipe:(indexPath.row == 0) ? SW_SCROLL_DIR_UP : SW_SCROLL_DIR_DOWN];
                }
                
            } else {
                
                self.tableView.userInteractionEnabled = YES;
                
            }
            
        } else {
            
            [self.tableView resetContentOffset:NO];
            self.tableView.userInteractionEnabled = YES;
            
        }
    }
}

#pragma mark Gesture Recognizers

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded){
        
        CGFloat xPercentage = [tap locationInView:self].x / self.frame.size.width;
        CGFloat yPercentage = [tap locationInView:self].y / self.frame.size.height;
        
        if (self.delegateAcapella){
            [self.delegateAcapella swAcapella:self onTap:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)press
{
    if (press.state == UIGestureRecognizerStateBegan){
        
        CGFloat xPercentage = [press locationInView:self].x / self.frame.size.width;
        CGFloat yPercentage = [press locationInView:self].y / self.frame.size.height;
        
        if (self.delegateAcapella){
            [self.delegateAcapella swAcapella:self onLongPress:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

@end




