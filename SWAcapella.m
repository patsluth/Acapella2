//
//  SWAcapella.m
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapella.h"
#import "SWAcapellaTitlesCloneContainer.h"
#import "SWAcapellaTitlesClone.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/libSluthware/UIPanWithForceGestureRecognizer.h"
#import "libsw/libSluthware/UILongPressWithForceGestureRecognizer.h"
#import "libsw/libSluthware/NSTimer+SW.h"
#import "libsw/libSluthware/UISnapBehaviorHorizontal.h"
#import "libsw/libSluthware/SWPrefs.h"

#import <CoreGraphics/CoreGraphics.h>

#define SWA_SCALE_3DTOUCH_NONE CGAffineTransformMakeScale(1.0, 1.0)
#define SWA_SCALE_3DTOUCH_PEEK CGAffineTransformMakeScale(1.06, 1.06)
#define SWA_SCALE_3DTOUCH_POP CGAffineTransformMakeScale(1.11, 1.11)

#define SWA_PULSE_SCALE = SWA_SCALE_3DTOUCH_PEEK;





@interface SWAcapella()
{
}

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;

@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tap2;
@property (readwrite, strong, nonatomic) UIPanWithForceGestureRecognizer *pan;
@property (readwrite, strong, nonatomic) UIPanWithForceGestureRecognizer *pan2;
@property (readwrite, strong, nonatomic) UILongPressWithForceGestureRecognizer *press;
@property (readwrite, strong, nonatomic) UILongPressWithForceGestureRecognizer *press2;

@property (strong, nonatomic) NSTimer *wrapAroundFallback;

@end





@implementation SWAcapella

#pragma mark - Associated Objects

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
    if (acapella) {
        [acapella.animator removeAllBehaviors];
        acapella.animator = nil;
        
        acapella.titlesCloneContainer = nil;
        acapella.titles.layer.opacity = 1.0;
        
        [acapella.tap.view removeGestureRecognizer:acapella.tap];
        [acapella.tap removeTarget:nil action:nil];
        acapella.tap = nil;
        
        [acapella.tap2.view removeGestureRecognizer:acapella.tap2];
        [acapella.tap2 removeTarget:nil action:nil];
        acapella.tap2 = nil;
        
        [acapella.pan.view removeGestureRecognizer:acapella.pan];
        [acapella.pan removeTarget:nil action:nil];
        acapella.pan = nil;
        
        [acapella.pan2.view removeGestureRecognizer:acapella.pan2];
        [acapella.pan2 removeTarget:nil action:nil];
        acapella.pan2 = nil;
        
        [acapella.press.view removeGestureRecognizer:acapella.press];
        [acapella.press removeTarget:nil action:nil];
        acapella.press = nil;
        
        [acapella.press2.view removeGestureRecognizer:acapella.press2];
        [acapella.press2 removeTarget:nil action:nil];
        acapella.press2 = nil;
        
        [acapella.referenceView layoutSubviews];
    }
    
    [SWAcapella setAcapella:nil ForObject:acapella.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    [SWAcapella setAcapella:nil ForObject:acapella.owner withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark - Init

- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;
{
    if (!referenceView) {
        //NSLog(@"SWAcapella error - Can't create SWAcapella. No referenceView supplied.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        self.referenceView = referenceView;
        
        if (preInitializeAction) {
            preInitializeAction(self);
        }
        
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    if (self.owner == nil || self.referenceView == nil) {
        //NSLog(@"SWAcapella error - owner[%@] and referenceView[%@] cannot be nil", [self.owner class], [self.referenceView class]);
        return;
    }
    
    [SWAcapella setAcapella:self ForObject:self.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    self.animator.delegate = self;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    self.tap.delegate = self;
    [self.referenceView addGestureRecognizer:self.tap];
    
    self.tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    self.tap2.delegate = self;
    self.tap2.numberOfTouchesRequired = 2;
    [self.referenceView addGestureRecognizer:self.tap2];
    
    self.pan = [[UIPanWithForceGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan.delegate = self;
    self.pan.forceDelegate = self;
    self.pan.minimumNumberOfTouches = self.pan.maximumNumberOfTouches = 1;
    [self.referenceView addGestureRecognizer:self.pan];
    
    self.pan2 = [[UIPanWithForceGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan2.delegate = self;
    self.pan2.forceDelegate = self;
    self.pan2.minimumNumberOfTouches = self.pan2.maximumNumberOfTouches = 2;
    [self.referenceView addGestureRecognizer:self.pan2];
    
    self.press = [[UILongPressWithForceGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
    self.press.delegate = self;
    self.press.forceDelegate = self;
    self.press.numberOfTouchesRequired = 1;
    self.press.minimumPressDuration = 0.3;
    [self.referenceView addGestureRecognizer:self.press];
    
    self.press2 = [[UILongPressWithForceGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
    self.press2.delegate = self;
    self.press2.forceDelegate = self;
    self.press2.numberOfTouchesRequired = 2;
    self.press2.minimumPressDuration = 0.3;
    [self.referenceView addGestureRecognizer:self.press2];
}

- (void)setupTitleCloneContainer
{
    if (!self.titlesCloneContainer) {
        
        self.titlesCloneContainer = [[SWAcapellaTitlesCloneContainer alloc] initWithFrame:self.titles.superview.frame];
        [self.referenceView addSubview:self.titlesCloneContainer];
        
        self.attachment = [[UIAttachmentBehavior alloc] initWithItem:self.titlesCloneContainer attachedToAnchor:CGPointZero];
        
    } else {
        
        CGPoint originalCenter = self.titlesCloneContainer.center;
        self.titlesCloneContainer.frame = self.titles.superview.frame;
        self.titlesCloneContainer.center = CGPointMake(originalCenter.x, self.titles.superview.center.y);
        
    }
}

- (void)refreshTitleClone
{
    if (!self.titlesCloneContainer) {
        return;
    }
    
    [self setupTitleCloneContainer];
    
    self.titlesCloneContainer.clone.titles = self.titles; //refresh
}

#pragma mark - UIGestureRecognizer

- (void)onTap:(UITapGestureRecognizer *)tap
{
    CGFloat xPercentage = [tap locationInView:tap.view].x / CGRectGetWidth(tap.view.bounds);
    //CGFloat yPercentage = [tap locationInView:tap.view].y / CGRectGetHeight(tap.view.bounds);
    SEL sel = nil;
    
    NSString *directionString = (xPercentage <= 0.25) ? @"tapleft" : (xPercentage > 0.75) ? @"tapright" : @"tapcentre";
    NSString *fingerString = (tap.numberOfTouchesRequired == 1) ? @"onefinger" : (tap.numberOfTouchesRequired == 2) ? @"twofinger" : nil;
    
    if (directionString && fingerString) {
        
        NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",
                         self.prefKeyPrefix,
                         @"gestures",
                         directionString,
                         fingerString,
                         [self forceKeyForForceType:UIForceTypeNone]]; //no force for taps
        NSString *selString = [SWPrefs valueForKey:key application:self.prefApplication];
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", selString]);
        
    }
    
    if (sel && [self.owner respondsToSelector:sel]) {
        [self.owner performSelectorOnMainThread:sel withObject:tap waitUntilDone:NO];
    }
}

- (void)onPan:(UIPanWithForceGestureRecognizer *)pan
{
    //smooth out multi touch pans by only following first finger location
    CGPoint panLocation = (pan.numberOfTouches > 0) ? [pan locationOfTouch:0 inView:pan.view] : [pan locationInView:pan.view];
    panLocation.y = self.titles.superview.center.y;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        [self.animator removeAllBehaviors];
        
        self.wrapAroundFallback = nil;
        
        [self setupTitleCloneContainer];
        self.titles.layer.opacity = 0.0;
        
        self.titlesCloneContainer.tag = 0;
        self.titlesCloneContainer.velocity = CGPointZero;
        
        self.attachment.anchorPoint = panLocation;
        [self.animator addBehavior:self.attachment];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        self.attachment.anchorPoint = panLocation;
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        [self.animator removeBehavior:self.attachment];
        
        //velocity after dragging
        CGPoint velocity = [pan velocityInView:pan.view];
        
        UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesCloneContainer]];
        d.allowsRotation = NO;
        d.resistance = 1.8;
        
        [self.animator addBehavior:d];
        [d addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titlesCloneContainer];
        
        __block SWAcapella *bself = self;
        __block UIDynamicItemBehavior *bd = d;
        
        d.action = ^{
            
            bself.titlesCloneContainer.velocity = [bd linearVelocityForItem:bself.titlesCloneContainer];
            
            CGPoint center = bself.titlesCloneContainer.center;
            CGFloat halfWidth = CGRectGetWidth(bself.titlesCloneContainer.bounds) / 2.0;
            CGFloat offScreenLeftX = -halfWidth;
            CGFloat offScreenRightX = CGRectGetWidth(bself.referenceView.bounds) + halfWidth;
            
            if (center.x < offScreenLeftX) {
                
                [bself.animator removeAllBehaviors];
                bself.titlesCloneContainer.center = CGPointMake(offScreenRightX, self.titles.superview.center.y);
                [self didWrapAround:-1 pan:pan];
                
            } else if (center.x > offScreenRightX) {
                
                [bself.animator removeAllBehaviors];
                bself.titlesCloneContainer.center = CGPointMake(offScreenLeftX, self.titles.superview.center.y);
                [self didWrapAround:1 pan:pan];
                
            } else {
                
                CGFloat absoluteVelocity = fabs([bd linearVelocityForItem:bself.titlesCloneContainer].x);
                
                //snap to center if we are moving to slow
                if (absoluteVelocity < CGRectGetMidX(bself.referenceView.bounds)) {
                    [bself snapToCenter];
                }
                
            }
            
        };
    }
}

- (void)onPress:(UILongPressWithForceGestureRecognizer *)press
{
    if (press.state == UIGestureRecognizerStateBegan) {
        
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    } else if (press.state == UIGestureRecognizerStateEnded) {
        
        CGFloat xPercentage = [press locationInView:press.view].x / CGRectGetWidth(press.view.bounds);
        //CGFloat yPercentage = [press locationInView:press.view].y / CGRectGetHeight(press.view.bounds);
        SEL sel = nil;
        
        NSString *directionString = (xPercentage <= 0.25) ? @"pressleft" : (xPercentage > 0.75) ? @"pressright" : @"presscentre";
        NSString *fingerString = (press.numberOfTouchesRequired == 1) ? @"onefinger" : (press.numberOfTouchesRequired == 2) ? @"twofinger" : nil;
        
        if (directionString && fingerString) {
            
            NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",
                             self.prefKeyPrefix,
                             @"gestures",
                             directionString,
                             fingerString,
                             [self forceKeyForForceType:press.forceType]];
            NSString *selString = [SWPrefs valueForKey:key application:self.prefApplication];
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", selString]);
            
        }
        
        if (sel && [self.owner respondsToSelector:sel]) {
            [self.owner performSelectorOnMainThread:sel withObject:press waitUntilDone:NO];
        }
        
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.referenceView.gestureRecognizers containsObject:gestureRecognizer]) {
        
        BOOL isControl = [touch.view isKindOfClass:[UIControl class]];
        return isControl ? !((UIControl *)touch.view).enabled : !isControl;
        
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.referenceView.gestureRecognizers containsObject:gestureRecognizer] &&
        [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint panVelocity = [pan velocityInView:pan.view];
        return (fabs(panVelocity.x) > fabs(panVelocity.y)); //only accept horizontal pans
        
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //only allow system gesture recognizers to begin if ours have failed
    return ([self.referenceView.gestureRecognizers containsObject:gestureRecognizer] &&
            ![self.referenceView.gestureRecognizers containsObject:otherGestureRecognizer]);
    
    return NO;
}

#pragma mark - UIForceGestureRecognizerDelegate

- (void)onForceChange:(UIGestureRecognizer<UIForceGestureRecognizer> * _Nonnull)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        switch (gestureRecognizer.forceType) {
            case UIForceTypeNone:
                self.referenceView.window.transform = SWA_SCALE_3DTOUCH_NONE;
                break;
                
            case UIForceTypePeek:
                self.referenceView.window.transform = SWA_SCALE_3DTOUCH_PEEK;
                break;
                
            case UIForceTypePop:
                self.referenceView.window.transform = SWA_SCALE_3DTOUCH_POP;
                break;
                
            default:
                self.referenceView.window.transform = SWA_SCALE_3DTOUCH_NONE;
                break;
        }
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
               gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        self.referenceView.window.transform = SWA_SCALE_3DTOUCH_NONE;
        
    }
}

#pragma mark - UIDynamics

/**
 *  Handle wrap around
 *
 *  @param direction left=(<0) right=(>0)
 *  @param pan UIPanWithForceGestureRecognizer that performed the wrap around
 */
- (void)didWrapAround:(NSInteger)direction pan:(UIPanWithForceGestureRecognizer *)pan
{
    self.titlesCloneContainer.tag = 6969;
    
    SEL sel = nil;
    
    NSString *directionString = (direction < 0) ? @"swipeleft" : (direction > 0) ? @"swiperight" : nil;
    NSString *fingerString = (pan.minimumNumberOfTouches == 1) ? @"onefinger" : (pan.minimumNumberOfTouches == 2) ? @"twofinger" : nil;
    
    if (directionString && fingerString) {
        
        NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",
                         self.prefKeyPrefix,
                         @"gestures",
                         directionString,
                         fingerString,
                         [self forceKeyForForceType:pan.forceType]];
        NSString *selString = [SWPrefs valueForKey:key application:self.prefApplication];
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", selString]);
        
    }
    
    if (sel && [self.owner respondsToSelector:sel]) {
        [self.owner performSelectorOnMainThread:sel withObject:pan waitUntilDone:NO];
    }
    
    
    
    self.wrapAroundFallback = [NSTimer scheduledTimerWithTimeInterval:1
                                                                block:^{
                                                                    [self finishWrapAround];
                                                                } repeats:NO];
}

- (void)finishWrapAround
{
    if (!self.titlesCloneContainer) {
        return;
    }

    [self refreshTitleClone];

    self.wrapAroundFallback = nil;

    if (self.titlesCloneContainer.tag == 6969) { //waiting for wrap around tag
        
        [self.animator removeAllBehaviors];

        self.titlesCloneContainer.tag = 0;
        
        //add original velocity
        UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesCloneContainer]];
        [self.animator addBehavior:d];
        
        
        CGFloat horizontalVelocity = self.titlesCloneContainer.velocity.x;
        //clamp horizontal velocity to its own width*(variable) per second
        horizontalVelocity = fminf(fabs(horizontalVelocity), CGRectGetWidth(self.titlesCloneContainer.bounds) * 3.5);
        horizontalVelocity = copysignf(horizontalVelocity, self.titlesCloneContainer.velocity.x);
        
        [d addLinearVelocity:CGPointMake(horizontalVelocity, 0.0) forItem:self.titlesCloneContainer];
        
        
        __block SWAcapella *bself = self;
        __block UIDynamicItemBehavior *bd = d;
        
        d.action = ^{
            
            CGFloat velocity = [bd linearVelocityForItem:bself.titlesCloneContainer].x;
            
            BOOL toSlow = fabs(velocity) < CGRectGetMidX(bself.referenceView.bounds);
            
            if (toSlow) {
                [bself snapToCenter];
            } else {
                
                CGFloat distanceFromCenter = bself.titlesCloneContainer.center.x - bself.titles.superview.center.x;
                
                //if we have a -ve velocity, after we wrap around we will have a positive value for distanceFromCenter
                //once we travel past the center, this value will be -ve as well. This also happens in the other direction
                //except with positive values. So we know we have travelled past the center if our velocity and our distance from
                //the center have the same sign (-ve && -ve || +ve && +ve)
                if (((distanceFromCenter < 0) == (velocity < 0))) {
                    //this will cause the toSlow condition to be met much quicker, snapping it to the centre
                    bd.resistance = 60;
                }
                
            }
            
        };
        
        self.titlesCloneContainer.velocity = CGPointZero;
        
    }
}

- (void)snapToCenter
{
    [self.animator removeAllBehaviors];
    
    if (!self.titlesCloneContainer) {
        return;
    }
    
    UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesCloneContainer]];
    d.allowsRotation = NO;
    d.resistance = 20;
    [self.animator addBehavior:d];
    
    CGPoint snapPoint = self.titles.superview.center;
    
    UISnapBehaviorHorizontal *s = [[UISnapBehaviorHorizontal alloc] initWithItem:self.titlesCloneContainer
                                                                        snapToPoint:snapPoint];
    s.damping = 0.15;
    [self.animator addBehavior:s];
    
    self.titlesCloneContainer.tag = 98765;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    //this method will get called if we stop dragging, but still have our finger down
    //check to see if we are dragging to make sure we dont remove all behaviours
    if (self.pan.state == UIGestureRecognizerStateChanged || self.pan2.state == UIGestureRecognizerStateChanged) {
        return;
    }
    
    if (self.titlesCloneContainer && self.titlesCloneContainer.tag == 98765) {
        self.titlesCloneContainer = nil;
    }
    
    [animator removeAllBehaviors];
}

#pragma mark - Public

- (void)pulseAnimateView
{
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.referenceView.window.transform = SWA_SCALE_3DTOUCH_PEEK;
                         
                     }completion:^(BOOL finished) {
                         
                         if (finished) {
                             
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  self.referenceView.window.transform = SWA_SCALE_3DTOUCH_NONE;
                                              } completion:^(BOOL finished) {
                                                  self.referenceView.window.transform = SWA_SCALE_3DTOUCH_NONE;
                                              }];
                             
                         } else {
                            
                             self.referenceView.window.transform = SWA_SCALE_3DTOUCH_NONE;
                             
                         }
                         
                     }];

}

#pragma mark - Internal

/**
 *  Get the corresponding force preference key for a UIForceType
 *
 *  @return force preference key
 */
- (NSString *)forceKeyForForceType:(UIForceType)forceType
{
    switch (forceType) {
        case UIForceTypeNone:
            return @"forcenone";
            break;
            
        case UIForceTypePeek:
            return @"forcepeek";
            break;
            
        case UIForceTypePop:
            return @"forcepop";
            break;
            
        default:
            return @"forcenone";
            break;
    }
}

- (void)setTitlesCloneContainer:(SWAcapellaTitlesCloneContainer *)titlesCloneContainer
{
    if (!titlesCloneContainer && _titlesCloneContainer) {
        [_titlesCloneContainer removeFromSuperview];
        self.titles.layer.opacity = 1.0;
    }
    
    _titlesCloneContainer = titlesCloneContainer;
    
    if (_titlesCloneContainer) {
        _titlesCloneContainer.clone.titles = self.titles;
    }
}

- (void)setWrapAroundFallback:(NSTimer *)wrapAroundFallback
{
    if (_wrapAroundFallback && !wrapAroundFallback) {
        [_wrapAroundFallback invalidate];
    }
    
    _wrapAroundFallback = wrapAroundFallback;
}

@end




