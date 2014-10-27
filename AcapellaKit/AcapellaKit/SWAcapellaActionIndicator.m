//
//  SWAcapellaActionIndicator.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaActionIndicator.h"
#import "SWAcapellaActionView.h"

@interface SWAcapellaActionIndicator()
{
}

@property (strong, nonatomic) NSMutableArray *actionQueue; //array of action view identifiers to be displayed in order
@property (strong, nonatomic) NSMutableArray *actionViews; //array of the actual views, saved to be reused
@property (weak, nonatomic) SWAcapellaActionView *currentActionView;

@end

@implementation SWAcapellaActionIndicator

#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
#ifdef DEBUG
        self.backgroundColor = [UIColor cyanColor];
#endif
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    for (UIView *view in self.actionViews){
        view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

#pragma mark Action Views

- (void)addViewToActionQueue:(SWAcapellaActionView *)view;
{
    if (![self actionViewForIdentifier:view.actionItemIdentifier]){
        [self.actionViews addObject:view];
        view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        view.alpha = 0.0;
    }
    
    [self.actionQueue addObject:view.actionItemIdentifier];
    
    if (!self.currentActionView){
        [self animateNextAction];
    }
}

- (SWAcapellaActionView *)actionViewForIdentifier:(NSString *)identifier
{
    for (SWAcapellaActionView *a in self.actionViews){
        if ([a.actionItemIdentifier isEqualToString:identifier]){
            return a;
        }
    }
    
    return nil;
}

- (void)animateNextAction
{
    if (self.actionQueue.count <= 0){
        return;
    }
    
    if (self.currentActionView){
        return;
    }
    
    self.currentActionView = [self actionViewForIdentifier:[self.actionQueue objectAtIndex:0]];
    
    if (self.currentActionView){
        
        [self addSubview:self.currentActionView];
        self.currentActionView.alpha = 0.0;
        
        [UIView animateWithDuration:self.currentActionView.displayTime / 2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.currentActionView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:self.currentActionView.displayTime / 2
                                                   delay:0.0
                                                 options:UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{
                                                  self.currentActionView.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished){
                                                  self.currentActionView = nil;
                                                  [self.actionQueue removeObjectAtIndex:0];
                                                  [self animateNextAction];
                                              }];
                         }];
        
    } else {
        
        [self animateNextAction];
        
    }
}

- (NSMutableArray *)actionQueue
{
    if (!_actionQueue){
        _actionQueue = [[NSMutableArray alloc] init];
    }
    return _actionQueue;
}

- (NSMutableArray *)actionViews
{
    if (!_actionViews){
        _actionViews = [[NSMutableArray alloc] init];
    }
    return _actionViews;
}

@end




