//
//  SWAcapella.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapella.h"
#import "SWAcapellaTitlesClone.h"

#import "libsw/libSluthware/NSTimer+SW.h"
#import "libsw/libSluthware/UISnapBehaviorHorizontal.h"

#import <CoreGraphics/CoreGraphics.h>





@interface SWAcapella()
{
}

@property (strong, nonatomic) UIDynamicAnimator *animator_titles;
@property (strong, nonatomic) UIAttachmentBehavior *behaviour_attachment_titles;

@property (readwrite, strong, nonatomic) UIView *titleCloneContainer;
@property (readwrite, nonatomic) CGPoint titleCloneContainer_LastVelocity;

@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *pan;

@end





@implementation SWAcapella

#pragma mark Associated Object

+ (SWAcapella *)acapellaForObject:(id)object
{
    return objc_getAssociatedObject(object, @selector(_acapella));
}

+ (void)setAcapella:(SWAcapella *)acapella ForObject:(id)object withPolicy:(objc_AssociationPolicy)policy
{
    objc_setAssociatedObject(object, @selector(_acapella), acapella, policy);
}

+ (void)removeAcapella:(SWAcapella *)acapella
{
    if (acapella){
        [acapella.animator_titles removeAllBehaviors];
        acapella.animator_titles = nil;
        
        if (acapella.titleCloneContainer){
            for (UIView *v in acapella.titleCloneContainer.subviews){
                [v removeFromSuperview];
            }
            [acapella.titleCloneContainer removeFromSuperview];
        }
        
        acapella.titleCloneContainer = nil;
        acapella.titles.layer.opacity = 1.0;
        
        [acapella.pan removeTarget:nil action:nil];
        [acapella.referenceView removeGestureRecognizer:acapella.pan];
        acapella.pan = nil;
        
        [acapella.tap removeTarget:nil action:nil];
        [acapella.tap.view removeGestureRecognizer:acapella.tap];
        acapella.tap = nil;
        
        [acapella.referenceView layoutSubviews];
    }
    
    [SWAcapella setAcapella:nil ForObject:acapella.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    [SWAcapella setAcapella:nil ForObject:acapella.owner withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark Init

- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;
{
    if (!referenceView){
        NSLog(@"SWAcapella error - Can't create SWAcapella. No referenceView supplied.");
        return nil;
    }
    
    self = [super init];
    
    if (self){
        self.referenceView = referenceView;
        
        if (preInitializeAction){
            preInitializeAction(self);
        }
        
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    if (self.owner == nil || self.referenceView == nil){
        NSLog(@"SWAcapella error - owner[%@] and referenceView[%@] cannot be nil", [self.owner class], [self.referenceView class]);
        return;
    }
    
    [SWAcapella setAcapella:self ForObject:self.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    
    self.animator_titles = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    self.animator_titles.delegate = self;
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan.delegate = self.owner;
    [self.referenceView addGestureRecognizer:self.pan];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self.owner action:@selector(onTap:)];
    self.tap.cancelsTouchesInView = YES;
    [self.referenceView addGestureRecognizer:self.tap];
    
}

- (CGPoint)referenceViewMidpoint
{
    return CGPointMake(CGRectGetWidth(self.referenceView.bounds) / 2, CGRectGetHeight(self.referenceView.bounds) / 2);
}

- (void)refreshTitleClones
{
    if (!self.titleCloneContainer){return;}
    
    //wait for the next iteration, so we know the original text has been updated
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    for (UIView *v in self.titleCloneContainer.subviews){ //update our label
        if ([v isKindOfClass:[SWAcapellaTitlesClone class]]){
            SWAcapellaTitlesClone *clone = (SWAcapellaTitlesClone *)v;
            clone.frame = clone.titles.frame;
            [clone setNeedsDisplay];
        }
    }
}

- (void)finishWrapAround
{
    [self refreshTitleClones];
    
    if (self.titleCloneContainer.tag == 6969){ //waiting for wrap around tag
        
        self.titleCloneContainer.tag = 0;

        [self.animator_titles removeAllBehaviors];
        
        //stop rotation
        UIDynamicItemBehavior *dynamicBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titleCloneContainer]];
        __weak UIDynamicItemBehavior *weakDynamicBehaviour = dynamicBehaviour;
        dynamicBehaviour.allowsRotation = NO;
        dynamicBehaviour.resistance = 1;
        [self.animator_titles addBehavior:dynamicBehaviour];
        
        //add original velocity
        [dynamicBehaviour addLinearVelocity:CGPointMake(self.titleCloneContainer_LastVelocity.x, 0.0) forItem:self.titleCloneContainer];
        
        
        dynamicBehaviour.action = ^{
            
            CGFloat distanceFromCenter = fabs(self.titleCloneContainer.center.x - self.referenceViewMidpoint.x);
            CGFloat absoluteVelocity = fabs([weakDynamicBehaviour linearVelocityForItem:self.titleCloneContainer].x);
            
            if (distanceFromCenter < 50 || absoluteVelocity < CGRectGetMidX(self.referenceView.bounds)){
                [self snapToCenter];
            }
            
        };
        
    }
}

- (void)snapToCenter
{
    [self.animator_titles removeAllBehaviors];
    
    UIDynamicItemBehavior *dynamicBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titleCloneContainer]];
    dynamicBehaviour.allowsRotation = NO;
    dynamicBehaviour.resistance = 2;
    [self.animator_titles addBehavior:dynamicBehaviour];
    
    UISnapBehaviorHorizontal *snapBehaviour = [[UISnapBehaviorHorizontal alloc] initWithItem:self.titleCloneContainer
                                                                                 snapToPoint:self.referenceViewMidpoint];
    snapBehaviour.damping = 0.15;
    [self.animator_titles addBehavior:snapBehaviour];
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:pan.view];
    location.y = self.referenceViewMidpoint.y;
    
    if (pan.state == UIGestureRecognizerStateBegan){
        
        [self.animator_titles removeAllBehaviors];
        
        
        self.titleCloneContainer.tag = 0;
        self.titleCloneContainer_LastVelocity = CGPointZero;
        
        
        CGRect x = self.referenceView.bounds;
        x.origin = CGPointZero;
        
        if (!self.titleCloneContainer){
            self.titleCloneContainer = [[UIView alloc] initWithFrame:x];
            self.titleCloneContainer.backgroundColor = [UIColor clearColor];
            self.titleCloneContainer.userInteractionEnabled = NO;
            [self.referenceView addSubview:self.titleCloneContainer];
        }
        
        
        CGFloat originalCenterX = self.titleCloneContainer.center.x;
        self.titleCloneContainer.frame = x;
        self.titleCloneContainer.center = CGPointMake(originalCenterX, location.y);
        
        
        //clear current clones
        for (UIView *v in self.titleCloneContainer.subviews){
            [v removeFromSuperview];
        }
        
        //create our CLONE
        SWAcapellaTitlesClone *titleClone = [[SWAcapellaTitlesClone alloc] initWithFrame:self.titles.frame];
        titleClone.backgroundColor = [UIColor clearColor];
        titleClone.titles = self.titles;
        [self.titleCloneContainer addSubview:titleClone];
        self.titles.layer.opacity = 0.0;
        
        [self refreshTitleClones];
        
    
        
        //add our attachment behaviour so we can drag our view
        self.behaviour_attachment_titles = [[UIAttachmentBehavior alloc] initWithItem:self.titleCloneContainer
                                                                     attachedToAnchor:location];
        [self.animator_titles addBehavior:self.behaviour_attachment_titles];
        
        
    } else if (pan.state == UIGestureRecognizerStateChanged){
        
        self.behaviour_attachment_titles.anchorPoint = location;
        
    } else if (pan.state == UIGestureRecognizerStateEnded){
        
        [self.animator_titles removeBehavior:self.behaviour_attachment_titles];
        
        //velocity after dragging
        CGPoint velocity = [pan velocityInView:pan.view];
        
        UIDynamicItemBehavior *dynamicBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titleCloneContainer]];
        __weak UIDynamicItemBehavior *weakDynamicBehaviour = dynamicBehaviour;
        dynamicBehaviour.allowsRotation = NO;
        dynamicBehaviour.resistance = 2;
        
        dynamicBehaviour.action = ^{
            
            void(^wrapAround)(NSNumber *direction) = ^(NSNumber *direction){ //0 left    1 right
                
                SEL wrapAroundSelector = @selector(onAcapellaWrapAround:);
                if ([self.owner respondsToSelector:wrapAroundSelector]){
                    [self.owner performSelectorOnMainThread:wrapAroundSelector withObject:direction waitUntilDone:NO];
                }
                
                //falback
                __block NSTimer *fallback = [NSTimer scheduledTimerWithTimeInterval:1
                                                                      block:^{
                                                                          [self finishWrapAround];
                                                                          fallback = nil;
                                                                      }repeats:NO];
                
            };
            

            
            self.titleCloneContainer_LastVelocity = [weakDynamicBehaviour linearVelocityForItem:self.titleCloneContainer];
            
            
            
            CGPoint center = self.titleCloneContainer.center;
            CGFloat offScreenLeftX = -CGRectGetMidX(self.titleCloneContainer.bounds);
            CGFloat offScreenRightX = CGRectGetMaxX(self.titleCloneContainer.bounds) + CGRectGetMidX(self.titleCloneContainer.bounds);
            
            if (center.x < offScreenLeftX){
                
                [self.animator_titles removeAllBehaviors];
                self.titleCloneContainer.tag = 6969;
                
                self.titleCloneContainer.center = CGPointMake(offScreenRightX, self.referenceViewMidpoint.y);
                wrapAround(@0);
                
            } else if (center.x > offScreenRightX){
                
                [self.animator_titles removeAllBehaviors];
                self.titleCloneContainer.tag = 6969;
                
                self.titleCloneContainer.center = CGPointMake(offScreenLeftX, self.referenceViewMidpoint.y);
                wrapAround(@1);
                
            } else {
                
                CGFloat absoluteVelocity = fabs([weakDynamicBehaviour linearVelocityForItem:self.titleCloneContainer].x);
                //snap to center if we are moving to slow
                if (absoluteVelocity < CGRectGetMidX(self.referenceView.bounds)){
                    [self snapToCenter];
                }
                
            }
            
        };
        
        [self.animator_titles addBehavior:dynamicBehaviour];
        [dynamicBehaviour addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titleCloneContainer];
    }
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    //this method will get called if we stop dragging, but still have our finger down
    //check to see if we are dragging to make sure we dont remove all behaviours
    if (self.pan.state == UIGestureRecognizerStateChanged){
        return;
    }
    
    [animator removeAllBehaviors];
}

@end




