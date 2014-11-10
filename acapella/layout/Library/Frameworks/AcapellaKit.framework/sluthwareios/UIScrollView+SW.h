//
//  UIScrollView+SW.h
//  sluthwareioslibrary
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

struct SWPage {
    NSInteger x;
    NSInteger y;
};
typedef struct SWPage SWPage;

CG_INLINE SWPage
SWPageMake(NSInteger x, NSInteger y)
{
    SWPage p; p.x = x; p.y = y; return p;
}




typedef enum {
    SW_SCROLL_DIR_NONE = 0,
    SW_SCROLL_DIR_LEFT = 1,
    SW_SCROLL_DIR_RIGHT = 2,
    SW_SCROLL_DIR_UP = 3,
    SW_SCROLL_DIR_DOWN = 4
} SW_SCROLL_DIRECTION;





@interface UIScrollView(SW) <UIScrollViewDelegate>

//responsible for updating these values in UIScrollViewDelegate
@property (readwrite, nonatomic) SW_SCROLL_DIRECTION currentScrollDirection;
@property (readwrite, nonatomic) CGPoint previousScrollOffset;
@property (readwrite, nonatomic) CGPoint currentVelocity;

- (SWPage)page;

- (SWPage)pagesAvailable;
- (SWPage)pageInCentre;

@end
