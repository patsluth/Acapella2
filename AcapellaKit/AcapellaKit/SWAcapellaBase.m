//
//  SWAcapellaBase.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaBase.h"

#import "SWAcapellaScrollingViewProtocol.h"
#import "SWAcapellaTableView.h"
#import "SWAcapellaScrollView.h"
#import "SWAcapellaPullToRefresh.h"

#import "UIScrollView+SW.h"
#ifdef DEBUG
    #import "UIColor+SW.h"
#endif





@interface SWAcapellaBase()
{
}

@property (readwrite, strong, nonatomic) SWAcapellaTableView *tableview;
@property (readwrite, strong, nonatomic) SWAcapellaScrollView *scrollview;
@property (strong, nonatomic) SWAcapellaPullToRefresh *pullToRefresh;

@end





@implementation SWAcapellaBase

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self) {
        
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        if (self.tableview){}
        if (self.pullToRefresh){}
        
        UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(onTap:)];
        oneFingerTap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:oneFingerTap];
        
        
        
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(onPress:)];
        longPress.minimumPressDuration = 0.7;
        [self addGestureRecognizer:longPress];
        
    }
    
    return self;
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                return (NSInteger)(self.bounds.size.height * 0.3);
                break;
                
            case 1:
                return self.bounds.size.height;
                break;
                
            case 2:
                return (NSInteger)(self.bounds.size.height * 0.3);
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
                    self.scrollview.delegate = self;
                    
                    [cell.contentView addSubview:self.scrollview];
                    
                    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollview
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:cell.contentView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1.0
                                                                                  constant:0.0]];
                    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollview
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:cell.contentView
                                                                                 attribute:NSLayoutAttributeBottom
                                                                                multiplier:1.0
                                                                                  constant:0.0]];
                    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollview
                                                                                 attribute:NSLayoutAttributeLeading
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:cell.contentView
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                multiplier:1.0
                                                                                  constant:0.0]];
                    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollview
                                                                                 attribute:NSLayoutAttributeTrailing
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:cell.contentView
                                                                                 attribute:NSLayoutAttributeRight
                                                                                multiplier:1.0
                                                                                  constant:0.0]];
                    
                }
                
                [cell.contentView layoutIfNeeded];
                [self.scrollview layoutIfNeeded];
                
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(swAcapella:willDisplayCell:atIndexPath:)]){
            [self.delegate swAcapella:self willDisplayCell:cell atIndexPath:indexPath];
        }
    }
}

#pragma mark - UIScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.scrollview == scrollView){
        self.tableview.scrollEnabled = NO;
    }
}

- (void)scrollViewDidScroll:(id<SWAcapellaScrollingViewProtocol>)scrollView
{
    scrollView.currentScrollDirection = [self determineSWScrollDirection:scrollView];
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.delegate performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
        }
    }
    
    if (self.tableview == scrollView){
        [self.pullToRefresh scrollViewDidScroll:(UIScrollView *)scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.tableview == scrollView){
        
        CGRect topAccessoryRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        CGRect mainContentRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        CGRect bottomAccessoryRect = [self.tableview rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        
        if (CGRectContainsPoint(topAccessoryRect, scrollView.contentOffset)){ //top accessory
            
            if (self.tableview.currentScrollDirection == SWScrollDirectionUp){
                *targetContentOffset = mainContentRect.origin;
            } else if (self.tableview.currentScrollDirection == SWScrollDirectionDown){
                *targetContentOffset = topAccessoryRect.origin;
            }
            
        } else if (CGRectContainsPoint(bottomAccessoryRect, CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + scrollView.frame.size.height))){
            
            if (self.tableview.currentScrollDirection == SWScrollDirectionUp){ //bottom accessory
                *targetContentOffset = CGPointMake(scrollView.contentOffset.x, (NSInteger)(scrollView.contentSize.height - scrollView.frame.size.height));
            } else if (self.tableview.currentScrollDirection == SWScrollDirectionDown){
                *targetContentOffset = mainContentRect.origin;
            }
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.tableview == scrollView){
        [self.pullToRefresh scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollview == scrollView){
        
        SWPage page = [self.scrollview page];
        
        BOOL shouldAnimate = (page.x != [self.scrollview pageInCentre].x); //centered already
        
        if (shouldAnimate){
            
            self.scrollview.userInteractionEnabled = NO;
            
            SWScrollDirection direction = SWScrollDirectionNone;
            
            if (page.x == 0 && page.y == 0){
                direction = SWScrollDirectionRight;
            } else if (page.x == 2 && page.y == 0) {
                direction = SWScrollDirectionLeft;
            }
            
            [self.scrollview startWrapAroundFallback];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(swAcapella:onSwipe:)]){
                [self.delegate swAcapella:self.scrollview onSwipe:direction];
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

- (SWScrollDirection)determineSWScrollDirection:(id<SWAcapellaScrollingViewProtocol>)scrollView
{
    SWScrollDirection direction = SWScrollDirectionNone;
    
    if (scrollView.contentOffset.x >= scrollView.previousContentOffset.x &&
        scrollView.contentOffset.y == scrollView.previousContentOffset.y){
        
        direction = SWScrollDirectionLeft;
        
    } else if (scrollView.contentOffset.x < scrollView.previousContentOffset.x &&
               scrollView.contentOffset.y == scrollView.previousContentOffset.y){
        
        direction = SWScrollDirectionRight;
        
    } else if (scrollView.contentOffset.x == scrollView.previousContentOffset.x &&
               scrollView.contentOffset.y >= scrollView.previousContentOffset.y){
        
        direction = SWScrollDirectionUp;
        
    } else if (scrollView.contentOffset.x == scrollView.previousContentOffset.x &&
               scrollView.contentOffset.y <= scrollView.previousContentOffset.y){
        
        direction = SWScrollDirectionDown;
        
    }
    
    scrollView.previousContentOffset = scrollView.contentOffset;
    
    return direction;
}

#pragma mark - Pull To Refresh

- (void)pullToRefreshActivated:(SWAcapellaPullToRefresh *)control
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(swAcapella:onSwipe:)]){
        if (control.direction == SWScrollDirectionUp || control.direction == SWScrollDirectionDown){
            [self.delegate swAcapella:self.tableview onSwipe:control.direction];
        }
    }
}

#pragma mark - Gesture Recognizers

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(swAcapella:onTap:percentage:)]) {
            
            CGFloat xPercentage = [tap locationInView:self].x / self.bounds.size.width;
            CGFloat yPercentage = [tap locationInView:self].y / self.bounds.size.height;
            
            [self.delegate swAcapella:self onTap:tap percentage:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)longPress
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(swAcapella:onLongPress:percentage:)]) {
            
            CGFloat xPercentage = [longPress locationInView:self].x / self.bounds.size.width;
            CGFloat yPercentage = [longPress locationInView:self].y / self.bounds.size.height;
            
            [self.delegate swAcapella:self onLongPress:longPress percentage:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

#pragma mark - Internal

- (void)layoutIfNeeded
{
    CGRect original = self.frame;
    
    [super layoutIfNeeded];
    
    if (!CGRectEqualToRect(original, self.frame)){ //only update on changed size
        
        [self.tableview reloadData];
        [self layoutIfNeeded];
        
    } else {
        
        [self.scrollview layoutIfNeeded];
        
    }
}

- (SWAcapellaTableView *)tableview
{
    if (CGRectIsEmpty(self.bounds)){ //dont create until we are sized
        return nil;
    }
    
    if (!_tableview) {
        
        _tableview = [[SWAcapellaTableView alloc] init];
        _tableview.dataSource = self;
        _tableview.delegate = self;
        
        [self addSubview:_tableview];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableview
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableview
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableview
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_tableview
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self layoutIfNeeded];
        
    }
    
    return _tableview;
}

- (SWAcapellaPullToRefresh *)pullToRefresh
{
    if (!_pullToRefresh){
        
        _pullToRefresh = [[SWAcapellaPullToRefresh alloc] init];
        
        [_pullToRefresh addTarget:self action:@selector(pullToRefreshActivated:) forControlEvents:UIControlEventApplicationReserved];
        
    }
    
    return _pullToRefresh;
}

- (void)dealloc
{
    if (self.scrollview) {
        
        for (UIView *v in self.scrollview.subviews) {
            [v removeFromSuperview];
        }
        
        [self.scrollview removeFromSuperview];
        self.scrollview = nil;
    }
    
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (self.tableview){
        [self.tableview removeFromSuperview];
        self.tableview = nil;
    }
}

@end




