//
//  SWAcapellaBase.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaBase.h"

#import "UIScrollView+SW.h"





@interface SWAcapellaBase()
{
}

@property (readwrite, strong, nonatomic) SWAcapellaScrollView *scrollview;

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
        
        if (self.scrollview){}
        
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

#pragma mark - UIScrollView

- (void)scrollViewWillBeginDragging:(SWAcapellaScrollView *)scrollView
{
}

- (void)scrollViewDidScroll:(SWAcapellaScrollView *)scrollView
{
    ScrollDirection scrollDirection = [self determineScrollDirectionAxis:scrollView];
    
    if (scrollDirection == ScrollDirectionVertical) {
        
    } else if (scrollDirection == ScrollDirectionHorizontal) {
        
    } else {
        
        if (scrollView.contentOffset.x != scrollView.defaultContentOffset.x && scrollView.contentOffset.y == scrollView.defaultContentOffset.y) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.defaultContentOffset.y);
        } else if (scrollView.contentOffset.x == scrollView.defaultContentOffset.x && scrollView.contentOffset.y != scrollView.defaultContentOffset.y) {
            scrollView.contentOffset = CGPointMake(scrollView.defaultContentOffset.x, scrollView.contentOffset.y);
        } else {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.defaultContentOffset.y);
        }
    }
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.delegate performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
        }
    }
}

- (ScrollDirection)determineScrollDirection:(SWAcapellaScrollView *)scrollView
{
    ScrollDirection scrollDirection;
    
    if (scrollView.defaultContentOffset.x != scrollView.contentOffset.x &&
        scrollView.defaultContentOffset.y != scrollView.contentOffset.y) {
        scrollDirection = ScrollDirectionCrazy;
    } else {
        if (scrollView.defaultContentOffset.x > scrollView.contentOffset.x) {
            scrollDirection = ScrollDirectionLeft;
        } else if (scrollView.defaultContentOffset.x < scrollView.contentOffset.x) {
            scrollDirection = ScrollDirectionRight;
        } else if (scrollView.defaultContentOffset.y > scrollView.contentOffset.y) {
            scrollDirection = ScrollDirectionUp;
        } else if (scrollView.defaultContentOffset.y < scrollView.contentOffset.y) {
            scrollDirection = ScrollDirectionDown;
        } else {
            scrollDirection = ScrollDirectionNone;
        }
    }
    
    return scrollDirection;
}

- (ScrollDirection)determineScrollDirectionAxis:(SWAcapellaScrollView *)scrollView
{
    ScrollDirection scrollDirection = [self determineScrollDirection:scrollView];
    
    switch (scrollDirection) {
        case ScrollDirectionLeft:
        case ScrollDirectionRight:
            return ScrollDirectionHorizontal;
            
        case ScrollDirectionUp:
        case ScrollDirectionDown:
            return ScrollDirectionVertical;
            
        default:
            return ScrollDirectionNone;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollview == scrollView) {
        
        SWPage page = [self.scrollview page];
        
        ScrollDirection direction = ScrollDirectionNone;
        
        if (page.x == 0 && page.y == 1) {
            direction = ScrollDirectionRight;
        } else if (page.x == 2 && page.y == 1) {
            direction = ScrollDirectionLeft;
        } else if (page.x == 1 && page.y == 0) {
            direction = ScrollDirectionDown;
        } else if (page.x == 1 && page.y == 2) {
            direction = ScrollDirectionUp;
        }
        
        if (direction == ScrollDirectionRight ||
            direction == ScrollDirectionLeft ||
            direction == ScrollDirectionDown ||
            direction == ScrollDirectionUp) {
            
            [self.scrollview startWrapAroundFallback];
            
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(swAcapella:onSwipe:)]) {
                    [self.delegate swAcapella:self.scrollview onSwipe:direction];
                }
            }
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
    [super layoutIfNeeded];
    [self.scrollview layoutIfNeeded];
}

- (SWAcapellaScrollView *)scrollview
{
    if (!_scrollview) {
        
        _scrollview = [[SWAcapellaScrollView alloc] init];
        _scrollview.delegate = self;
        
        [self addSubview:_scrollview];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollview
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollview
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollview
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollview
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self layoutIfNeeded];
        
    }
    
    return _scrollview;
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
}

@end




