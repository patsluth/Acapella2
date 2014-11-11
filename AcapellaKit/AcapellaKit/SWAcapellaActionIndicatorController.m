//
//  SWAcapellaActionIndicatorController.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2014-10-28.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import "SWAcapellaActionIndicatorController.h"
#import "libsw/sluthwareios/sluthwareios.h"

@interface SWAcapellaActionIndicatorController()
{
}

@property (weak, nonatomic) SWAcapellaActionIndicator *currentActionIndicator;

@property (strong, nonatomic) NSMutableArray *actionIndicatorQueue; //array of action view identifiers to be displayed in order
@property (strong, nonatomic) NSMutableArray *actionIndicatorPool; //array of the actual views, saved to be reused

@end

@implementation SWAcapellaActionIndicatorController

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.clipsToBounds = YES;
        
#ifdef DEBUG
        //self.backgroundColor = [UIColor cyanColor];
#endif
    }
    
    return self;
}

- (void)addActionIndicatorToQueue:(SWAcapellaActionIndicator *)view
{
    if (![self actionIndicatorWithIdentifierIfExists:view.actionIndicatorIdentifier]){
        view.actionIndicatorDelegate = self;
        [self.actionIndicatorPool addObject:view];
    }
    
    if (!self.currentActionIndicator){
        [self.actionIndicatorQueue addObject:view.actionIndicatorIdentifier];
        [self showNextActionIndicator:YES];
    } else {
        if ([self.currentActionIndicator.actionIndicatorIdentifier isEqualToString:view.actionIndicatorIdentifier]){
            [self.currentActionIndicator delayBySeconds:self.currentActionIndicator.actionIndicatorDisplayTime];
        } else {
            [self.actionIndicatorQueue addObject:view.actionIndicatorIdentifier];
        }
    }
}

- (void)addActionIndicatorToPool:(SWAcapellaActionIndicator *)view
{
    if (![self actionIndicatorWithIdentifierIfExists:view.actionIndicatorIdentifier]){
        view.actionIndicatorDelegate = self;
        [self.actionIndicatorPool addObject:view];
    }
}

- (SWAcapellaActionIndicator *)actionIndicatorWithIdentifierIfExists:(NSString *)identifier
{
    for (SWAcapellaActionIndicator *view in self.actionIndicatorPool){
        if ([view.actionIndicatorIdentifier isEqualToString:identifier]){
            return view;
        }
    }
    
    return nil;
}

- (void)showNextActionIndicator:(BOOL)animated
{
    if (self.currentActionIndicator){
        return;
    }
    
    if (self.actionIndicatorQueue.count <= 0){
        return;
    }
    
    self.currentActionIndicator = [self actionIndicatorWithIdentifierIfExists:[self.actionIndicatorQueue objectAtIndex:0]];
    
    if (self.currentActionIndicator){
        
        self.currentActionIndicator.alpha = 0.0;
        [self addSubview:self.currentActionIndicator];
        
        [self.currentActionIndicator setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
        
        [self.currentActionIndicator showAnimated:animated];
    }
}

#pragma mark SWAcapellaActionIndicatorDelegate

- (void)actionIndicatorWillShow:(SWAcapellaActionIndicator *)actionIndicator
{
}

- (void)actionIndicatorDidShow:(SWAcapellaActionIndicator *)actionIndicator
{
}

- (void)actionIndicatorWillHide:(SWAcapellaActionIndicator *)actionIndicator
{
}

- (void)actionIndicatorDidHide:(SWAcapellaActionIndicator *)actionIndicator
{
    self.currentActionIndicator.alpha = 0.0;
    [self.currentActionIndicator removeFromSuperview];
    self.currentActionIndicator = nil;
    
    if (self.actionIndicatorQueue.count > 0 &&
        [[self.actionIndicatorQueue objectAtIndex:0] isEqualToString:actionIndicator.actionIndicatorIdentifier]){
        [self.actionIndicatorQueue removeObjectAtIndex:0];
    }
    
    [self showNextActionIndicator:YES];
}

#pragma mark Getters/Setters

- (NSMutableArray *)actionIndicatorQueue
{
    if (!_actionIndicatorQueue){
        _actionIndicatorQueue = [[NSMutableArray alloc] init];
    }
    return _actionIndicatorQueue;
}

- (NSMutableArray *)actionIndicatorPool
{
    if (!_actionIndicatorPool){
        _actionIndicatorPool = [[NSMutableArray alloc] init];
    }
    return _actionIndicatorPool;
}

@end




