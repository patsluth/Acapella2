//
//  SWAcapellaTitlesCloneContainer.m
//  acapella
//
//  Created by Pat Sluth on 2015-07-27.
//
//

#import "SWAcapellaTitlesCloneContainer.h"
#import "SWacapellaTitlesClone.h"





@implementation SWAcapellaTitlesCloneContainer

#pragma mark - Init

- (id)init
{
    self = [super init];
    
    if (self){
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
    self.velocity = CGPointZero;
    self.clone = [[SWAcapellaTitlesClone alloc] init];
    [self addSubview:self.clone];
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    [self.clone setNeedsDisplay];
}

@end




