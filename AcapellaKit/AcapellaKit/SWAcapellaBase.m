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
#import "SWAcapellaPullToRefresh.h"

@interface SWAcapellaBase()
{
}

//gesture recognizers
@property (strong, nonatomic) UITapGestureRecognizer *oneFingerTap;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) SWAcapellaPullToRefresh *pullToRefresh;

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
        
        CGFloat newPullToRefreshHeight = self.frame.size.height * VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE;
        [self.pullToRefresh setSize:CGSizeMake(newPullToRefreshHeight, newPullToRefreshHeight)];
        [self.pullToRefresh setCenterX:self.tableview.frame.size.width / 2];
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
        return 3;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                return self.frame.size.height * VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE;
                break;
                
            case 1:
                return self.frame.size.height;
                break;
                
            case 2:
                return self.frame.size.height * VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE;
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
                return @"swacapella_accessory";
                break;
                
            case 1:
                return @"swacapella_main";
                break;
                
            case 2:
                return @"swacapella_accessory";
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
        
#ifdef DEBUG
        CGFloat hue = ( arc4random() % 256 / 256.0 );
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
        cell.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
#endif
        
        cell.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0){
            if (indexPath.row == 1){
                
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
        if ([self.delegateAcapella respondsToSelector:@selector(swAcapella:willDisplayCell:atIndexPath:)]){
            [self.delegateAcapella swAcapella:self willDisplayCell:cell atIndexPath:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegateAcapella){
        if ([self.delegateAcapella respondsToSelector:@selector(swAcapella:didEndDisplayingCell:atIndexPath:)]){
            [self.delegateAcapella swAcapella:self didEndDisplayingCell:cell atIndexPath:indexPath];
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
    
    if (self.tableview == scrollView){
        [self.pullToRefresh scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    scrollView.currentVelocity = velocity;
    
    if (self.tableview == scrollView){
        
        CGRect topAccessoryRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        CGRect mainContentRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        CGRect bottomAccessoryRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        if (CGRectContainsPoint(topAccessoryRect, scrollView.contentOffset)){ //top accessory
            
            if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_UP){
                *targetContentOffset = mainContentRect.origin;
            } else if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_DOWN){
                *targetContentOffset = topAccessoryRect.origin;
            }
            
        } else if (CGRectContainsPoint(bottomAccessoryRect, CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + scrollView.frame.size.height))){
            
            if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_UP){ //bottom accessory
                *targetContentOffset = CGPointMake(scrollView.contentOffset.x, (NSInteger)(scrollView.contentSize.height - scrollView.frame.size.height));
            } else if (self.tableview.currentScrollDirection == SW_SCROLL_DIR_DOWN){
                *targetContentOffset = mainContentRect.origin;
            }
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.tableview == scrollView){
        [self.pullToRefresh scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
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
        
        if (self.pullToRefresh){
            [self.pullToRefresh scrollViewDidEndDecelerating:scrollView];
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
    if (self.delegateAcapella){
        
        CGFloat xPercentage = [tap locationInView:self].x / self.frame.size.width;
        CGFloat yPercentage = [tap locationInView:self].y / self.frame.size.height;
        
        [self.delegateAcapella swAcapella:self onTap:tap percentage:CGPointMake(xPercentage, yPercentage)];
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)longPress
{
    if (self.delegateAcapella){
        
        CGFloat xPercentage = [longPress locationInView:self].x / self.frame.size.width;
        CGFloat yPercentage = [longPress locationInView:self].y / self.frame.size.height;
        
        [self.delegateAcapella swAcapella:self onLongPress:longPress percentage:CGPointMake(xPercentage, yPercentage)];
    }
}

#pragma mark Pull To Refresh

- (void)pullToRefreshActivated:(SWAcapellaPullToRefresh *)control
{
    if (self.delegateAcapella){
        if (control.swaState == 1){
            [self.delegateAcapella swAcapella:self.tableview onSwipe:SW_SCROLL_DIR_DOWN];
        } else if (control.swaState == 2){
            [self.delegateAcapella swAcapella:self.tableview onSwipe:SW_SCROLL_DIR_UP];
        }
    }
}

- (SWAcapellaPullToRefresh *)pullToRefresh
{
    if (!_pullToRefresh){
        _pullToRefresh = [[SWAcapellaPullToRefresh alloc] init];
        
        [_pullToRefresh addTarget:self action:@selector(pullToRefreshActivated:) forControlEvents:UIControlEventApplicationReserved];
        [self.tableview addSubview:_pullToRefresh];
    }
    
    if (self.delegateAcapella){
        _pullToRefresh.image = [self.delegateAcapella swAcapellaImageForPullToRefreshControl];
        _pullToRefresh.tintColor = [self.delegateAcapella swAcapellaTintColorForPullToRefreshControl];
    }
    
    return _pullToRefresh;
}

@end




