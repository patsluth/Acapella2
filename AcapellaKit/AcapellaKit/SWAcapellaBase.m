//
//  SWAcapellaBase.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaBase.h"

#import "SWAcapellaScrollView.h"

#import "UIScrollView+SW.h"

#ifdef DEBUG
    #import "UIColor+SW.h"
#endif





@interface SWAcapellaBase()
{
}

@property (readwrite, strong, nonatomic) SWAcapellaScrollView *scrollview;

@end





@implementation SWAcapellaBase

- (id)layersNotWantingVibrancy
{
    return @[self.scrollview.layer];
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
#ifdef DEBUG
        self.backgroundColor = [UIColor clearColor];
#endif
        
        if (self.scrollview){}
        
        //tap
        UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        oneFingerTap.cancelsTouchesInView = YES;
        [self addGestureRecognizer:oneFingerTap];
        
        //longpress
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
        longPress.minimumPressDuration = 0.7;
        [self addGestureRecognizer:longPress];
        
        //swipe up
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeUp];
        //swipe down
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipeDown];
    }
    
    return self;
}

#pragma mark - UIScrollView

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (self.scrollview == scrollView){
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]){
            [self.delegate performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    SWPage page = [self.scrollview page];
    
    BOOL shouldAnimate = (page.x != [self.scrollview pageInCentre].x); //centered already
    
    if (shouldAnimate){
        
        self.scrollview.userInteractionEnabled = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(swAcapella:onSwipe:)]){
            if (page.x == 0){
                [self.delegate swAcapella:self onSwipe:UISwipeGestureRecognizerDirectionRight];
            } else if (page.x == 2){
                [self.delegate swAcapella:self onSwipe:UISwipeGestureRecognizerDirectionLeft];
            }
        }
        
        [self.scrollview startWrapAroundFallback];
        
    } else {
        
        [self.scrollview resetContentOffset:NO];
        
    }
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    if (self.scrollview == scrollView){
//    }
//}

#pragma mark - Gesture Recognizers

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(swAcapella:onTap:percentage:)]){
            
            CGFloat xPercentage = [tap locationInView:self].x / self.bounds.size.width;
            CGFloat yPercentage = [tap locationInView:self].y / self.bounds.size.height;
            
            [self.delegate swAcapella:self onTap:tap percentage:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)longPress
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(swAcapella:onLongPress:percentage:)]){
            
            CGFloat xPercentage = [longPress locationInView:self].x / self.bounds.size.width;
            CGFloat yPercentage = [longPress locationInView:self].y / self.bounds.size.height;
            
            [self.delegate swAcapella:self onLongPress:longPress percentage:CGPointMake(xPercentage, yPercentage)];
        }
    }
}

- (void)onSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(swAcapella:onSwipe:)]){
            [self.delegate swAcapella:self onSwipe:swipe.direction];
        }
    }
}

#pragma mark - Internal

- (void)setFrame:(CGRect)frame
{
    //CGRect original = frame;
    
    [super setFrame:frame];
    
//    if (!CGRectEqualToRect(original, self.frame)){ //only update on changed size
//        
//        [self.scrollview layoutIfNeeded];
//        
//    }
}

- (void)layoutIfNeeded
{
    //CGRect original = self.frame;
    
    [super layoutIfNeeded];
    
//    if (!CGRectEqualToRect(original, self.frame)){ //only update on changed size
//        
//        [self.scrollview layoutIfNeeded];
//        
//    }
}

- (SWAcapellaScrollView *)scrollview
{
    if (CGRectIsEmpty(self.bounds)){ //dont create until we are sized
        return nil;
    }
    
    if (!_scrollview){
        
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
}

@end




