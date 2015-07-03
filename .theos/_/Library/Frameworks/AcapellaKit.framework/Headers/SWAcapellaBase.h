//
//  SWAcapellaBase.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-11-07.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SWAcapellaBase;
@class SWAcapellaScrollView;





@protocol SWAcapellaDelegate <NSObject, UIScrollViewDelegate>

@optional

- (void)scrollViewDidScroll:(SWAcapellaScrollView *)scrollView;

- (void)swAcapella:(SWAcapellaBase *)swAcapella onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage;
- (void)swAcapella:(SWAcapellaBase *)swAcapella onSwipe:(UISwipeGestureRecognizerDirection)direction;
- (void)swAcapella:(SWAcapellaBase *)swAcapella onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage;

@end





@interface SWAcapellaBase : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) id<SWAcapellaDelegate> delegate;

@property (readonly, strong, nonatomic) SWAcapellaScrollView *scrollview;

@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end




