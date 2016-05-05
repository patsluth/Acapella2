//
//  SWAcapellaTitlesClone.m
//  Acapella2
//
//  Created by Pat Sluth on 2015-07-18.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapellaTitlesClone.h"





@interface SWAcapellaTitlesClone()

@end





@implementation SWAcapellaTitlesClone

#pragma mark - Init

- (id)init
{
	if (self = [super init]) {
		
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.userInteractionEnabled = NO;
		self.backgroundColor = [UIColor clearColor];
		
	}
	
	return self;
}

- (void)setTitles:(UIView *)titles
{
	_titles = titles;
	
	[self setNeedsDisplay];
}

#pragma mark Rendering

- (void)drawRect:(CGRect)rect
{
	if (self.titles && !self.hidden) {
		
		CALayer *layer = self.titles.layer.modelLayer;
		
		if (!layer) {
			layer = self.titles.layer;
		}
		
		if (layer) {
			
			// make titles layer visible and render in the clone
			layer.opacity = 1.0;
			
			CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
			[layer renderInContext:UIGraphicsGetCurrentContext()];
			
			layer.opacity = 0.0;
			
		}
		
		
	}
}


@end



