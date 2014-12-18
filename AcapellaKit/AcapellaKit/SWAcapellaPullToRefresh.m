//
//  SWAcapellaPullToRefresh.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-12-17.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaPullToRefresh.h"
#import "libsw/sluthwareios/sluthwareios.h"

@interface SWAcapellaPullToRefresh()
{
}

@property (strong, nonatomic) UIImageView *imageView;
@property (readwrite, nonatomic) NSInteger swaState;

@end

@implementation SWAcapellaPullToRefresh

#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.backgroundColor = [UIColor clearColor];
        
#ifdef DEBUG
        self.backgroundColor = [UIColor blackColor];
#endif
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        self.alpha = 0.0;
        
        self.swaState = 0;
    }
    
    return self;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.imageView setSize:frame.size];
}

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView){
        
        CGFloat minYOffsetToTriggerRefresh = scrollView.superview.frame.size.height * VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE;
        CGFloat offsetPercentage = 0.0;
        
        if (scrollView.contentOffset.y <= 0.0){
            
            CGFloat newOrigin = -self.frame.size.height; //lock to top of content
            
            if ([self swaState:scrollView]){ //until we reach the threshold
                newOrigin = (scrollView.contentOffset.y + minYOffsetToTriggerRefresh) - self.frame.size.height; //keep in position once we reach threshold
            }
            
            [self setOriginY:newOrigin];
            offsetPercentage = fabsf(scrollView.contentOffset.y / minYOffsetToTriggerRefresh);
            
        } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height){
            
            CGFloat newOrigin = scrollView.contentSize.height; //lock to bottom of content
            
            if ([self swaState:scrollView]){ //until we reach the threshold
                newOrigin = (scrollView.contentOffset.y + scrollView.frame.size.height) - minYOffsetToTriggerRefresh; //keep in position once we reach threshold
            }
            
            [self setOriginY:newOrigin];
            offsetPercentage = fabsf(((scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height) / minYOffsetToTriggerRefresh);
            
        }
        
        self.alpha = offsetPercentage;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self swaState:scrollView] != 0){
        self.swaState = [self swaState:scrollView];
    }
    
    self.alpha = 0.0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.swaState != 0){
        [self sendActionsForControlEvents:UIControlEventApplicationReserved];
    }
    
    self.swaState = 0;
}

#pragma mark SWAcapellaPullToRefresh

- (NSInteger)swaState:(UIScrollView *)scrollView
{
    if (scrollView && scrollView.superview){
        
        CGFloat minYOffsetToTriggerRefresh = scrollView.superview.frame.size.height * VIEW_HEIGHT_PERCENTAGE_TO_ACTIVATE;
        
        if (scrollView.contentOffset.y <= -minYOffsetToTriggerRefresh){
            
            return 1;
            
        } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height + minYOffsetToTriggerRefresh){
            
            return 2;
            
        }
    }
    
    return 0;
}

@end




