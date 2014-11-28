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
        
        self.tableview = [[SWAcapellaTableView alloc] init];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.tableview];
        
        self.tableview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        
        [self.tableview reloadData];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self initGestureRecognizers];

        self.acapellaTopAccessoryHeight = 0.0;
        self.acapellaBottomAccessoryHeight = 0.0;
    }
    
    return self;
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

- (void)setFrame:(CGRect)frame
{
    CGRect original = self.frame;
    
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(original, frame)){
        if (self.tableview){
            [self.tableview reloadData];
        }
    }
}

- (void)setAcapellaTopAccessoryHeight:(CGFloat)acapellaTopAccessoryHeight
{
    _acapellaTopAccessoryHeight = acapellaTopAccessoryHeight;
    
    if (self.tableview){
        [self.tableview reloadData];
    }
}

- (void)setAcapellaBottomAccessoryHeight:(CGFloat)acapellaBottomAccessoryHeight
{
    _acapellaBottomAccessoryHeight = acapellaBottomAccessoryHeight;
    
    if (self.tableview){
        [self.tableview reloadData];
    }
}

- (void)dealloc
{
    [self resetGestureRecognizers];
    
    if (self.scrollview){
        
        for (UIView *v in self.scrollview.subviews){
            [v removeFromSuperview];
        }
        
        [self.scrollview removeFromSuperview];
        self.scrollview = nil;
    }
    
    for (UIView *v in self.subviews){
        [v removeFromSuperview];
    }
    
    if (self.tableview){
        self.tableview = nil;
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
                return self.frame.size.height * 3;
                break;
                
            case 1:
                return (self.acapellaTopAccessoryHeight <= 0.0) ? self.frame.size.height * 0.4 : self.acapellaTopAccessoryHeight;
                break;
                
            case 2:
                return self.frame.size.height;
                break;
                
            case 3:
                return (self.acapellaBottomAccessoryHeight <= 0.0) ? self.frame.size.height * 0.4 : self.acapellaBottomAccessoryHeight;
                break;
                
            case 4:
                return self.frame.size.height * 3;
                break;
                
            default:
                break;
        }
    }
    
    return 0;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0){
            if (indexPath.row == 2){
                
                if (!self.scrollview){
                    self.scrollview = [[SWAcapellaScrollView alloc] init];
                }
                
                self.scrollview.delegate = self;
                self.scrollview.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                
                [cell.contentView addSubview:self.scrollview];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegateAcapella){
        if ([self.delegateAcapella respondsToSelector:@selector(swAcapalle:willDisplayCell:atIndexPath:)]){
            [self.delegateAcapella swAcapalle:self willDisplayCell:cell atIndexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegateAcapella){
        if ([self.delegateAcapella respondsToSelector:@selector(swAcapalle:didEndDisplayingCell:atIndexPath:)]){
            [self.delegateAcapella swAcapalle:self didEndDisplayingCell:cell atIndexPath:indexPath];
        }
    }
}

#pragma mark UIScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollview == scrollView){
        self.tableview.scrollEnabled = NO;
    }
}

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
    
    if (self.tableview == scrollView){
        
        if (velocity.y > 0.2){
            //return;
        }
        
        NSIndexPath *targetIndexPath = [self.tableview indexPathForRowAtPoint:*targetContentOffset];
        
        if (targetIndexPath.section != 0){
            return;
        }
        
        //auto set to the top and bottom of these so we snap nicely
        if (targetIndexPath.row == 0){
            CGRect edgeOfWorldTopRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            *targetContentOffset = CGPointMake(edgeOfWorldTopRect.origin.x,
                                               (edgeOfWorldTopRect.origin.y + edgeOfWorldTopRect.size.height) -
                                               self.tableview.frame.size.height);
            return;
        } else if (targetIndexPath.row == 4){
            *targetContentOffset = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]].origin;
            return;
        }
        
        
        
        CGFloat contentOffsetCenterY = targetContentOffset->y + (self.frame.size.height / 2);
        
        if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_UP){
            contentOffsetCenterY = targetContentOffset->y + self.frame.size.height;
        } else if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_UP){
            contentOffsetCenterY = targetContentOffset->y;
        }
        
        NSIndexPath *centredIndexPath = [self.tableview indexPathForRowAtPoint:CGPointMake(self.tableview.frame.size.width / 2,
                                                                                            contentOffsetCenterY)];
        CGRect centredIndexPathFrame = [self.tableview rectForRowAtIndexPath:centredIndexPath];
        
        
        
        
        
        switch (centredIndexPath.row) {
            case 0:
                *targetContentOffset = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].origin;
                break;
                
            case 1:
                *targetContentOffset = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].origin;
                break;
                
            case 2:
            {
                NSIndexPath *aboveCentredIndexPath = [NSIndexPath indexPathForRow:centredIndexPath.row - 1 inSection:0];
                NSIndexPath *belowCentredIndexPath = [NSIndexPath indexPathForRow:centredIndexPath.row + 1 inSection:0];
                CGRect aboveCentredIndexPathFrame = [self.tableview rectForRowAtIndexPath:aboveCentredIndexPath];
                CGRect belowCentredIndexPathFrame = [self.tableview rectForRowAtIndexPath:belowCentredIndexPath];
                
                //these two variables are so we can calucalate the percentage of the accessory view on screen
                CGFloat distToTopAccessory = targetContentOffset->y -
                (aboveCentredIndexPathFrame.origin.y + aboveCentredIndexPathFrame.size.height);
                CGFloat distToBottomAccessory = (targetContentOffset->y + centredIndexPathFrame.size.height) -
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
                    *targetContentOffset = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].origin;
                    
                }
            }
                break;
                
            case 3:
            {
                CGRect mainCellFrame = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                CGRect bottomAccessoryCellFrame = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                *targetContentOffset = CGPointMake(mainCellFrame.origin.x,
                                                   mainCellFrame.origin.y + bottomAccessoryCellFrame.size.height);
            }
                break;
                
            case 4:
                *targetContentOffset = centredIndexPathFrame.origin;
                break;
                
            default:
                *targetContentOffset = centredIndexPathFrame.origin;
                break;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollview == scrollView){
        
        SWPage page = [self.scrollview page];
        
        BOOL shouldAnimate = (page.x != [self.scrollview pageInCentre].x); //centered already
        
        if (shouldAnimate){
            
            scrollView.userInteractionEnabled = NO;
            
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
            
        }
        
    } else if (self.tableview == scrollView){
        
        scrollView.userInteractionEnabled = NO;
        
        CGFloat contentOffsetCenterY;
        
        if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_UP){
            contentOffsetCenterY = self.tableview.contentOffset.y + self.frame.size.height - 5;
        } else if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_DOWN){
            contentOffsetCenterY = self.tableview.contentOffset.y + 5;
        }
        
        NSIndexPath *centredIndexPath = [self.tableview indexPathForRowAtPoint:CGPointMake(self.tableview.contentOffset.x,
                                                                                          contentOffsetCenterY)];
        
        if (centredIndexPath.section == 0){
            
            if (centredIndexPath.row == 0 || centredIndexPath.row == [self.tableview numberOfRowsInSection:0] - 1){
                
                [self.tableview startWrapAroundFallback];
                
                if (self.delegateAcapella){
                    [self.delegateAcapella swAcapella:self.tableview
                                              onSwipe:(centredIndexPath.row == 0) ? SW_SCROLL_DIR_DOWN : SW_SCROLL_DIR_UP];
                }
                
            } else {
                
                self.tableview.userInteractionEnabled = YES;
                
            }
            
        } else {
            
            [self.tableview resetContentOffset:NO];
            
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.scrollview == scrollView){
        if (self.tableview){
            self.tableview.scrollEnabled = YES;
        }
    }
}

#pragma mark Gesture Recognizers

- (void)onTap:(UITapGestureRecognizer *)tap
{
    CGFloat xPercentage = [tap locationInView:self].x / self.frame.size.width;
    CGFloat yPercentage = [tap locationInView:self].y / self.frame.size.height;
    
    if (self.delegateAcapella){
        [self.delegateAcapella swAcapella:self onTap:tap percentage:CGPointMake(xPercentage, yPercentage)];
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)longPress
{
    CGFloat xPercentage = [longPress locationInView:self].x / self.frame.size.width;
    CGFloat yPercentage = [longPress locationInView:self].y / self.frame.size.height;
    
    if (self.delegateAcapella){
        [self.delegateAcapella swAcapella:self onLongPress:longPress percentage:CGPointMake(xPercentage, yPercentage)];
    }
}

@end




