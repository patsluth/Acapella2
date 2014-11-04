//
//  UIView+SW.h
//  sluthwareios
//
//  Created by Pat Sluth on 2014-03-02.
//  Copyright (c) 2014 Sluthware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(SW)

- (void)setOrigin:(CGPoint)newOrigin;
- (void)setOriginX:(CGFloat)newOrigin;
- (void)setUpperRightOriginX:(CGFloat)newOrigin;
- (void)setLowerRightOriginX:(CGFloat)newOrigin;
- (void)setOriginY:(CGFloat)newOrigin;
- (void)setSize:(CGSize)newSize;
- (void)setSizeX:(CGFloat)newSize;
- (void)setSizeY:(CGFloat)newSize;
- (void)setCenterX:(CGFloat)newCenter;
- (void)setCenterY:(CGFloat)newCenter;

@end




