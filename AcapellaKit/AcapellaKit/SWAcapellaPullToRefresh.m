//
//  SWAcapellaPullToRefresh.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-12-17.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaPullToRefresh.h"





@interface SWAcapellaPullToRefresh()
{
}

@property (readwrite, nonatomic) SWScrollDirection direction;

@end





@implementation SWAcapellaPullToRefresh

#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.backgroundColor = [UIColor clearColor];
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        
        self.alpha = 0.0;
        
        self.direction = SWScrollDirectionNone;
    }
    
    return self;
}

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView){
//        
//        CGFloat minYOffsetToTriggerRefresh = scrollView.superview.frame.size.height * VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE;
//        CGFloat offsetPercentage = 0.0;
//        
//        if (scrollView.contentOffset.y <= 0.0){
//            
//            CGFloat newOrigin = -self.frame.size.height; //lock to top of content
//            
//            if ([self swaState:scrollView]){ //until we reach the threshold
//                newOrigin = (scrollView.contentOffset.y + minYOffsetToTriggerRefresh) - self.frame.size.height; //keep in position once we reach threshold
//            }
//            
//            [self setOriginY:newOrigin];
//            offsetPercentage = fabsf(scrollView.contentOffset.y / minYOffsetToTriggerRefresh);
//            
//        } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height){
//            
//            CGFloat newOrigin = scrollView.contentSize.height; //lock to bottom of content
//            
//            if ([self swaState:scrollView]){ //until we reach the threshold
//                newOrigin = (scrollView.contentOffset.y + scrollView.frame.size.height) - minYOffsetToTriggerRefresh; //keep in position once we reach threshold
//            }
//            
//            [self setOriginY:newOrigin];
//            offsetPercentage = fabsf(((scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height) / minYOffsetToTriggerRefresh);
//            
//        }
//        
//        self.alpha = offsetPercentage;
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self direction:scrollView] != 0){
        self.direction = [self direction:scrollView];
    }
    
    self.alpha = 0.0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.direction != SWScrollDirectionNone){
        [self sendActionsForControlEvents:UIControlEventApplicationReserved];
    }
    
    self.direction = SWScrollDirectionNone;
}

#pragma mark SWAcapellaPullToRefresh

- (SWScrollDirection)direction:(UIScrollView *)scrollView
{
    if (scrollView && scrollView.superview){
        
        CGFloat minYOffsetToTriggerRefresh = scrollView.superview.frame.size.height * 0.15;
        
        if (scrollView.contentOffset.y <= -minYOffsetToTriggerRefresh){
            
            return SWScrollDirectionUp;
            
        } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + minYOffsetToTriggerRefresh){
            
            return SWScrollDirectionDown;
            
        }
    }
    
    return 0;
}

@end




