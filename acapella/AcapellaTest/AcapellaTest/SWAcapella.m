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

#import "libsw/libSluthware/NSTimer+SW.h"
#import "libsw/libSluthware/UISnapBehaviorHorizontal.h"

#import <CoreGraphics/CoreGraphics.h>





@interface SWAcapella()
{
}

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;

@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *pan;
@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tap;
@property (readwrite, strong, nonatomic) UILongPressGestureRecognizer *press;

@property (strong, nonatomic) NSTimer *wrapAroundFallback;






@property (strong, nonatomic) void (^wrapAroundAction)(void);
@property (strong, nonatomic) void (^finishWrapAroundAction)(void);

@end





@implementation SWAcapella

#pragma mark - Associated Object

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
        [acapella.animator removeAllBehaviors];
        acapella.animator = nil;
        
        acapella.titlesCloneContainer = nil;
        acapella.titles.layer.opacity = 1.0;
        
        [acapella.referenceView removeGestureRecognizer:acapella.pan];
        [acapella.pan removeTarget:nil action:nil];
        acapella.pan = nil;
        
        [acapella.tap.view removeGestureRecognizer:acapella.tap];
        [acapella.tap removeTarget:nil action:nil];
        acapella.tap = nil;
        
        [acapella.press.view removeGestureRecognizer:acapella.press];
        [acapella.press removeTarget:nil action:nil];
        acapella.press = nil;
        
        [acapella.referenceView layoutSubviews];
    }
    
    [SWAcapella setAcapella:nil ForObject:acapella.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    [SWAcapella setAcapella:nil ForObject:acapella.owner withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark - Init

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
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    self.animator.delegate = self;
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan.delegate = self.owner;
    [self.referenceView addGestureRecognizer:self.pan];
    
    self.tap = [[UITapGestureRecognizer alloc] init];
    self.tap.delegate = self.owner;
    self.tap.cancelsTouchesInView = YES;
    [self.referenceView addGestureRecognizer:self.tap];
    
    self.press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
    self.press.delegate = self.owner;
    self.press.minimumPressDuration = 0.7;
    [self.referenceView addGestureRecognizer:self.press];
}

- (void)setupTitleCloneContainer
{
    if (!self.titlesCloneContainer){
        
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
    if (!self.titlesCloneContainer){
        return;
    }
    
    [self setupTitleCloneContainer];
    
    self.titlesCloneContainer.clone.titles = self.titles; //refresh
}

#pragma mark - Gesture Recognizers

- (void)onPan:(UIPanGestureRecognizer *)pan
{
    CGPoint panLocation = [pan locationInView:pan.view];
    panLocation.y = self.titles.superview.center.y;
    
    if (pan.state == UIGestureRecognizerStateBegan){
        
        [self.animator removeAllBehaviors];
        
        self.wrapAroundFallback = nil;
        
        [self setupTitleCloneContainer];
        self.titles.layer.opacity = 0.0;
        
        self.titlesCloneContainer.tag = 0;
        self.titlesCloneContainer.velocity = CGPointZero;
        
        self.attachment.anchorPoint = panLocation;
        [self.animator addBehavior:self.attachment];
        
    } else if (pan.state == UIGestureRecognizerStateChanged){
        
        self.attachment.anchorPoint = panLocation;
        
    } else if (pan.state == UIGestureRecognizerStateEnded){
        
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
            
            if (center.x < offScreenLeftX){
                
                [bself.animator removeAllBehaviors];
                bself.titlesCloneContainer.center = CGPointMake(offScreenRightX, self.titles.superview.center.y);
                 [self didWrapAround:@(-1)];
                
            } else if (center.x > offScreenRightX){
                
                [bself.animator removeAllBehaviors];
                bself.titlesCloneContainer.center = CGPointMake(offScreenLeftX, self.titles.superview.center.y);
                [self didWrapAround:@(1)];
                
            } else {
                
                CGFloat absoluteVelocity = fabs([bd linearVelocityForItem:bself.titlesCloneContainer].x);
                
                //snap to center if we are moving to slow
                if (absoluteVelocity < CGRectGetMidX(bself.referenceView.bounds)){
                    [bself snapToCenter];
                }
                
            }
            
        };
    }
}

- (void)onPress:(UILongPressGestureRecognizer *)press
{
//    if (press.state == UIGestureRecognizerStateBegan){
//        NSLog(@"BEGIN");
//    } else if (press.state == UIGestureRecognizerStateEnded){
//        NSLog(@"END");
//    }8
}

#pragma mark - UIDynamics

// direction < 0 - decrease
// direction = 0 - no change
// direction > 0 - increase
- (void)didWrapAround:(NSNumber *)direction
{
    self.titlesCloneContainer.tag = 6969;
    
    SEL wrapAroundSelector = @selector(onAcapellaWrapAround:);
    if ([self.owner respondsToSelector:wrapAroundSelector]){
        [self.owner performSelectorOnMainThread:wrapAroundSelector withObject:direction waitUntilDone:NO];
    }
    
    self.wrapAroundFallback = [NSTimer scheduledTimerWithTimeInterval:1
                                                                block:^{
                                                                    [self finishWrapAround];
                                                                } repeats:NO];
}

- (void)finishWrapAround
{
    if (!self.titlesCloneContainer){
        return;
    }

    [self refreshTitleClone];

    self.wrapAroundFallback = nil;

    if (self.titlesCloneContainer.tag == 6969){ //waiting for wrap around tag
        
        [self.animator removeAllBehaviors];

        self.titlesCloneContainer.tag = 0;
        
        //add original velocity
        UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesCloneContainer]];
        [self.animator addBehavior:d];
        
        
        CGFloat horizontalVelocity = self.titlesCloneContainer.velocity.x;
        //clamp horizontal velocity to its own width*3 per second
        horizontalVelocity = fminf(fabs(horizontalVelocity), CGRectGetWidth(self.titlesCloneContainer.bounds) * 4);
        horizontalVelocity = copysignf(horizontalVelocity, self.titlesCloneContainer.velocity.x);
        
        [d addLinearVelocity:CGPointMake(horizontalVelocity, 0.0) forItem:self.titlesCloneContainer];
        
        
        __block SWAcapella *bself = self;
        __block UIDynamicItemBehavior *bd = d;
        
        d.action = ^{
            
            CGFloat velocity = [bd linearVelocityForItem:bself.titlesCloneContainer].x;
            
            BOOL toSlow = fabs(velocity) < CGRectGetMidX(bself.referenceView.bounds);
            
            if (toSlow){
                [bself snapToCenter];
            } else {
                
                CGFloat distanceFromCenter = bself.titlesCloneContainer.center.x - bself.titles.superview.center.x;
                
                //if we have a -ve velocity, after we wrap around we will have a positive value for distanceFromCenter
                //once we travel past the center, this value will be -ve as well. This also happens in the other direction
                //except with positive values. So we know we have travelled past the center if our velocity and our distance from
                //the center have the same sign (-ve && -ve || +ve && +ve)
                if (((distanceFromCenter < 0) == (velocity < 0))){
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
    
    if (!self.titlesCloneContainer){
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
    if (self.pan.state == UIGestureRecognizerStateChanged){
        return;
    }
    
    if (self.titlesCloneContainer && self.titlesCloneContainer.tag == 98765){
        self.titlesCloneContainer = nil;
    }
    
    [animator removeAllBehaviors];
}

#pragma mark - Public

- (void)pulseAnimateView:(UIView *)view
{
    if (!self.titlesCloneContainer){
        [self setupTitleCloneContainer];
        [self refreshTitleClone];
    }
    
    if (!view){
        view = self.titlesCloneContainer;
    }
    
    self.titles.layer.opacity = 0.0;
    
    [view.layer removeAllAnimations];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.07, 1.07);
                     }completion:^(BOOL finished){
                         
                         if (finished){
                             
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              } completion:^(BOOL finished){
                                                  view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  if (!self.animator.isRunning){
                                                      self.titlesCloneContainer = nil;
                                                  }
                                              }];
                             
                         } else {
                             if (!self.animator.isRunning){
                                 self.titlesCloneContainer = nil;
                             }
                         }
                         
                     }];

}

+ (NSString *)prefKeyByDrillingUpFromView:(UIView *)view
{
    //    id a = NSStringFromClass([self.view.superview class]);
    //    id b = NSStringFromClass([self.view.superview.superview class]);
    //    id c = NSStringFromClass([self.view.window.rootViewController class]);
    //    NSLog(@"Acapella System Media Controls Log %@-%@-%@", a, b, c);
    
    UIView *curView = view.superview;
    
    while (curView){
        
        //Control Centre
        if ([NSStringFromClass([curView class]) isEqualToString:@"SBControlCenterRootView"]){
            return @"cc_";
        }
        
        //Lock Screen
        if ([NSStringFromClass([curView class]) isEqualToString:@"SBLockScreenView"]){
            return @"ls_";
        }
        
        //OnTapMusic - class will be null if tweak is not installed
        if (objc_getClass("OTMView") && [NSStringFromClass([curView class]) isEqualToString:@"OTMView"]){
            return @"otm_";
        }
        
        //Auxo LE - class will be null if tweak is not installed
        if (objc_getClass("AuxoCollectionView") && [NSStringFromClass([curView class]) isEqualToString:@"AuxoCollectionView"]){
            return @"auxo_";
        }
        
        //Vertex - Vertex has no classes ?
        if ([NSStringFromClass([curView class]) isEqualToString:@"SBAppSwitcherContainer"]){
            return @"vertex_";
        }
        
        curView = curView.superview;
        
    }
    
    return @"undefined_";
}

#pragma mark - Internal

- (void)setTitlesCloneContainer:(SWAcapellaTitlesCloneContainer *)titlesCloneContainer
{
    if (!titlesCloneContainer && _titlesCloneContainer){
        [_titlesCloneContainer removeFromSuperview];
        self.titles.layer.opacity = 1.0;
    }
    
    _titlesCloneContainer = titlesCloneContainer;
    
    if (_titlesCloneContainer){
        _titlesCloneContainer.clone.titles = self.titles;
    }
}

- (void)setWrapAroundFallback:(NSTimer *)wrapAroundFallback
{
    if (_wrapAroundFallback && !wrapAroundFallback){
        [_wrapAroundFallback invalidate];
    }
    
    _wrapAroundFallback = wrapAroundFallback;
}

@end




