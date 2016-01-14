//
//  SWAcapella.m
//  Acapella2
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"
#import "SWAcapellaTitlesCloneContainer.h"
#import "SWAcapellaTitlesClone.h"

#import "libsw/libSluthware/libSluthware.h"
//TODO: REMOVE
#import "libsw/libSluthware/UISnapBehaviorHorizontal.h"
#import "libsw/libSluthware/NSTimer+SW.h"
#import "libsw/libSluthware/SWPrefs.h"

#import <CoreGraphics/CoreGraphics.h>
#import <MobileGestalt/MobileGestalt.h>

#define SWA_SCALE_3DTOUCH_NONE CGAffineTransformMakeScale(1.0, 1.0)
#define SWA_SCALE_3DTOUCH_PEEK CGAffineTransformMakeScale(1.06, 1.06)
#define SWA_SCALE_3DTOUCH_POP CGAffineTransformMakeScale(1.11, 1.11)

#define SWA_PULSE_SCALE = SWA_SCALE_3DTOUCH_PEEK;



#define SW_PIRACY  NSURL *url = [NSURL URLWithString:@"https://saurik.sluthware.com"]; \
NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url \
cachePolicy:NSURLRequestReloadIgnoringCacheData \
timeoutInterval:60.0]; \
[urlRequest setHTTPMethod:@"POST"]; \
\
CFStringRef udid = (CFStringRef)MGCopyAnswer(kMGUniqueDeviceID); \
NSString *postString = [NSString stringWithFormat:@"udid=%@&packageID=%@", udid, @"org.thebigboss.acapella2"]; \
[urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]]; \
CFRelease(udid); \
\
[NSURLConnection sendAsynchronousRequest:urlRequest \
queue:[NSOperationQueue mainQueue] \
completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) { \
\
if (!connectionError) { \
\
NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; \
\
/*  0 = Purchased */ \
/*  1 = Not Purchased */ \
/*  X = Cydia Error */ \
\
if ([dataString isEqualToString:@"1"]) { \
\
UIAlertController *controller = [UIAlertController \
alertControllerWithTitle:[NSString stringWithFormat:@"%@", @(arc4random())] \
message:nil \
preferredStyle:UIAlertControllerStyleAlert]; \
\
UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" \
style:UIAlertActionStyleCancel \
handler:nil]; \
[controller addAction:cancelAction]; \
\
if (!self.referenceView.window.rootViewController.presentedViewController) { \
[self.referenceView.window.rootViewController presentViewController:controller animated:NO completion:nil]; \
} \
\
} \
} \
}]; \





@interface SWAcapella()
{
}

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;

@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *pan;

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
        
        [acapella.pan.view removeGestureRecognizer:acapella.pan];
        [acapella.pan removeTarget:nil action:nil];
        acapella.pan = nil;
        [acapella.referenceView layoutSubviews];
        
    }
    
    [SWAcapella setAcapella:nil ForObject:acapella.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    [SWAcapella setAcapella:nil ForObject:acapella.owner withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark - Init

- (id)initWithReferenceView:(UIView *)referenceView preInitializeAction:(void (^)(SWAcapella *a))preInitializeAction;
{
    if (!referenceView) {
        NSLog(@"SWAcapella error - Can't create SWAcapella. No referenceView supplied.");
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
        NSLog(@"SWAcapella error - owner[%@] and referenceView[%@] cannot be nil", [self.owner class], [self.referenceView class]);
        return;
    }
    
    [SWAcapella setAcapella:self ForObject:self.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    self.animator.delegate = self;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    self.tap.delegate = self;
    [self.referenceView addGestureRecognizer:self.tap];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan.delegate = self;
    self.pan.minimumNumberOfTouches = self.pan.maximumNumberOfTouches = 1;
    [self.referenceView addGestureRecognizer:self.pan];
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
    
    if (xPercentage <= 0.25) { // left
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_tapleft]);
    } else if (xPercentage > 0.75) { // right
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_tapright]);
    } else { // centre
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_tapcentre]);
    }
    
    if (sel && [self.owner respondsToSelector:sel]) {
        [self.owner performSelectorOnMainThread:sel withObject:tap waitUntilDone:NO];
    }
    
    
    [self pulseAnimateView];
    
    
    SW_PIRACY;
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    CGPoint panLocation = [pan locationInView:pan.view];
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
        
        __unsafe_unretained SWAcapella *weakSelf = self;
        __unsafe_unretained UIDynamicItemBehavior *weakD = d;
        
        d.action = ^{
            
            weakSelf.titlesCloneContainer.velocity = [weakD linearVelocityForItem:weakSelf.titlesCloneContainer];
            
            CGPoint center = weakSelf.titlesCloneContainer.center;
            CGFloat halfWidth = CGRectGetWidth(weakSelf.titlesCloneContainer.bounds) / 2.0;
            CGFloat offScreenLeftX = -halfWidth;
            CGFloat offScreenRightX = CGRectGetWidth(weakSelf.referenceView.bounds) + halfWidth;
            
            if (center.x < offScreenLeftX) {
                
                [weakSelf.animator removeAllBehaviors];
                weakSelf.titlesCloneContainer.center = CGPointMake(offScreenRightX, weakSelf.titles.superview.center.y);
                [weakSelf didWrapAround:-1 pan:pan];
                
            } else if (center.x > offScreenRightX) {
                
                [weakSelf.animator removeAllBehaviors];
                weakSelf.titlesCloneContainer.center = CGPointMake(offScreenLeftX, weakSelf.titles.superview.center.y);
                [weakSelf didWrapAround:1 pan:pan];
                
            } else {
                
                CGFloat absoluteVelocity = fabs([weakD linearVelocityForItem:weakSelf.titlesCloneContainer].x);
                
                //snap to center if we are moving to slow
                if (absoluteVelocity < CGRectGetMidX(weakSelf.referenceView.bounds)) {
                    [weakSelf snapToCenter];
                }
                
            }
            
        };
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

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    //only allow system gesture recognizers to begin if ours have failed
//    return ([self.referenceView.gestureRecognizers containsObject:gestureRecognizer] &&
//            ![self.referenceView.gestureRecognizers containsObject:otherGestureRecognizer]);
//    
//    return NO;
//}

#pragma mark - UIDynamics

/**
 *  Handle wrap around
 *
 *  @param direction left=(<0) right=(>0)
 *  @param pan UIPanGestureRecognizer that performed the wrap around
 */
- (void)didWrapAround:(NSInteger)direction pan:(UIPanGestureRecognizer *)pan
{
    self.titlesCloneContainer.tag = 6969;
    
    SEL sel = nil;
    
    if (direction < 0) { // left
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_swipeleft]);
    } else if (direction > 0) { // right
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_swiperight]);
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
        
        
        __unsafe_unretained SWAcapella *weakSelf = self;
        __unsafe_unretained UIDynamicItemBehavior *weakD = d;
        
        d.action = ^{
            
            CGFloat velocity = [weakD linearVelocityForItem:weakSelf.titlesCloneContainer].x;
            
            BOOL toSlow = fabs(velocity) < CGRectGetMidX(weakSelf.referenceView.bounds);
            
            if (toSlow) {
                [weakSelf snapToCenter];
            } else {
                
                CGFloat distanceFromCenter = weakSelf.titlesCloneContainer.center.x - weakSelf.titles.superview.center.x;
                
                //if we have a -ve velocity, after we wrap around we will have a positive value for distanceFromCenter
                //once we travel past the center, this value will be -ve as well. This also happens in the other direction
                //except with positive values. So we know we have travelled past the center if our velocity and our distance from
                //the center have the same sign (-ve && -ve || +ve && +ve)
                if (((distanceFromCenter < 0) == (velocity < 0))) {
                    //this will cause the toSlow condition to be met much quicker, snapping it to the centre
                    weakD.resistance = 60;
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
    
    
    
    //TODO: CHECK CONTENT OFFSET
    if (self.pan.state == UIGestureRecognizerStateChanged) {
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
//- (NSString *)forceKeyForForceType:(UIForceType)forceType
//{
//    return nil;
////    switch (forceType) {
////        case UIForceTypeNone:
////            return @"forcenone";
////            break;
////            
////        case UIForceTypePeek:
////            return @"forcepeek";
////            break;
////            
////        case UIForceTypePop:
////            return @"forcepop";
////            break;
////            
////        default:
////            return @"forcenone";
////            break;
////    }
//}

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




