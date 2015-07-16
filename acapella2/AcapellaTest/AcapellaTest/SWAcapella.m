//
//  SWAcapella.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapella.h"

#import "libsw/libSluthware/UISnapBehaviorHorizontal.h"

#import <objc/runtime.h>





@interface SWAcapella()
{
}

@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *pan;

@property (strong, nonatomic) UIAttachmentBehavior *behaviour_attachment_titles;
@property (strong, nonatomic) UIView *titlesSnapshot;

@end





@implementation SWAcapella

#pragma mark Associated Object

static SWAcapella *_acapella;

+ (SWAcapella *)acapellaForOwner:(id)owner
{
    return objc_getAssociatedObject(owner, &_acapella);
}

+ (void)setAcapella:(SWAcapella *)acapella ForOwner:(id)owner
{
    objc_setAssociatedObject(owner, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)removeAcapella:(SWAcapella *)acapella
{
    [SWAcapella setAcapella:nil ForOwner:acapella.owner];
    //objc_removeAssociatedObjects(acapella);
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
    
    self.animator_titles = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    self.animator_titles.delegate = self;
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan.delegate = self.owner;
    [self.referenceView addGestureRecognizer:self.pan];
    
    
    
    
    //TODO: read prefs
    if (self.topSlider){
        self.animator_topSlider = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
        self.animator_topSlider.delegate = self;
    }
    if (self.bottomSlider){
        self.animator_bottomSlider = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
        self.animator_bottomSlider.delegate = self;
    }
    
    
//    if (self.topSlider || self.bottomSlider){ //we dont need these gestures if the slider views are both nil
//        
//        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
//        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
//        
//        swipeUp.delegate = self.owner;
//        swipeDown.delegate = self.owner;
//        
//        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
//        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
//        
//        [self.referenceView addGestureRecognizer:swipeUp];
//        [self.referenceView addGestureRecognizer:swipeDown];
//        
//        [self.pan requireGestureRecognizerToFail:swipeUp];
//        [self.pan requireGestureRecognizerToFail:swipeDown];
//        
//    }
    
}

- (CGPoint)defaultTitlesCenter
{
    return CGPointMake(CGRectGetMidX(self.referenceView.bounds), self.titles.center.y);
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:pan.view];
    location.y = self.defaultTitlesCenter.y;
    
    if (pan.state == UIGestureRecognizerStateBegan){
        
        [self.animator_titles removeAllBehaviors];
        
        //add our attachment behaviour so we can drag our view
        self.behaviour_attachment_titles = [[UIAttachmentBehavior alloc] initWithItem:self.titles attachedToAnchor:location];
        [self.animator_titles addBehavior:self.behaviour_attachment_titles];
        
    } else if (pan.state == UIGestureRecognizerStateChanged){
        
        self.behaviour_attachment_titles.anchorPoint = location;
        
    } else if (pan.state == UIGestureRecognizerStateEnded){
        
        [self.animator_titles removeBehavior:self.behaviour_attachment_titles];
        
        //velocity after dragging
        CGPoint velocity = [pan velocityInView:pan.view];
        
        UIDynamicItemBehavior *dynamicBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titles]];
        dynamicBehaviour.allowsRotation = NO;
        dynamicBehaviour.resistance = 2;
        __weak UIDynamicItemBehavior *weakDynamicBehaviour = dynamicBehaviour;
        
        dynamicBehaviour.action = ^{
            
            void(^snapToCenter)() = ^{
                
                UISnapBehaviorHorizontal *snapBehaviour = [[UISnapBehaviorHorizontal alloc] initWithItem:self.titles
                                                                                             snapToPoint:self.defaultTitlesCenter];
                snapBehaviour.damping = 0.15;
                [self.animator_titles addBehavior:snapBehaviour];
            };
            
            void(^wrapAround)(NSNumber *direction) = ^(NSNumber *direction){ //0 left    1 right
                
                [self.animator_titles removeAllBehaviors];
                
                //stop rotation
                UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titles]];
                d.allowsRotation = NO;
                d.resistance = 1;
                [self.animator_titles addBehavior:d];
                
                //damp velocity to 90%
               // [d addLinearVelocity:CGPointMake(velocity.x * 0.9, 0.0) forItem:self.titles];
                [d addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titles];
                
                
                SEL wrapAroundSelector = @selector(onAcapellaWrapAround:);
                if ([self.owner respondsToSelector:wrapAroundSelector]){
                    [self.owner performSelectorOnMainThread:wrapAroundSelector withObject:direction waitUntilDone:NO];
                }
                
                
                __weak UIDynamicItemBehavior *wd = d;
                
                d.action = ^{
                    
                    CGFloat distanceFromCenter = fabs(self.titles.center.x - self.defaultTitlesCenter.x);
                    
                    if (distanceFromCenter < 50){
                        
                        CGPoint curVelocity = [wd linearVelocityForItem:self.titles];
                        curVelocity.x *= -1; //reverse velocity
                        [wd addLinearVelocity:curVelocity forItem:self.titles]; //apply reversed velocity, to stop
                        
                        snapToCenter();
                        
                        wd.action = nil;
                    }
                    
                };
                
            };
            
            
            CGPoint upperLeft = CGPointMake(self.titles.center.x - CGRectGetMidX(self.titles.bounds),
                                            self.titles.center.y - CGRectGetMidY(self.titles.bounds));
            CGPoint upperRight = CGPointMake(upperLeft.x + CGRectGetMaxX(self.titles.bounds),
                                             upperLeft.y - CGRectGetMaxY(self.titles.bounds));
            
            if (upperLeft.x < -CGRectGetMaxX(self.titles.bounds)){ //just off left side of screen
                self.titles.center = CGPointMake(CGRectGetMaxX(self.referenceView.bounds) + CGRectGetMidX(self.titles.bounds), self.defaultTitlesCenter.y);
                wrapAround(@0);
            } else if (upperRight.x > CGRectGetMaxX(self.referenceView.bounds) + CGRectGetMaxX(self.titles.bounds)){ //just off right side of screen
                self.titles.center = CGPointMake(-CGRectGetMidX(self.titles.bounds), self.defaultTitlesCenter.y);
                wrapAround(@1);
            } else {
                //snap to center if we are moving to slow
                if (fabs([dynamicBehaviour linearVelocityForItem:self.titles].x) < CGRectGetMidX(self.referenceView.bounds)){
                    weakDynamicBehaviour.action = nil;
                    snapToCenter();
                }
            }
            
        };
        
        [self.animator_titles addBehavior:dynamicBehaviour];
        [dynamicBehaviour addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titles];
    }
}

#pragma mark UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    //this method will get called if we stop dragging, but still have our finger down
    //check to see if we are dragging to make sure we dont remove all behaviours
    if (self.pan.state == UIGestureRecognizerStateChanged){
        return;
    }
    
    //reset our tag, which we change in order to block frame changes while moving
    self.titles.tag = 0;
    self.titles.superview.tag = 0;
    
    self.titles.center = self.defaultTitlesCenter;
    
    //NSLog(@"PAT REMOVING BEHAVIOURS");
    
    [animator removeAllBehaviors];
}

@end




