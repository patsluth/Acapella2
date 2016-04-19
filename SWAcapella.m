//
//  SWAcapella.m
//  Acapella2
//
//  Created by Pat Sluth on 2015-07-08.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"

#import "libsw/libSluthware/libSluthware.h"
//TODO: REMOVE
#import "libsw/libSluthware/UISnapBehaviorHorizontal.h"
#import "libsw/libSluthware/NSTimer+SW.h"
#import "libsw/libSluthware/SWPrefs.h"

#import "UIKit/UIPreviewForceInteractionProgress.h"

#import <CoreGraphics/CoreGraphics.h>
#import <MobileGestalt/MobileGestalt.h>





typedef NS_ENUM(NSInteger, SWAcapellaTitlesState) {
	SWAcapellaTitlesStateNone,
	SWAcapellaTitlesStateWaitingForWrapAround
};





#define SWACAPELLA_PULSE_SCALE CGAffineTransformMakeScale(1.05, 1.05);

#define SW_PIRACY NSURL *url = [NSURL URLWithString:@"https://saurik.sluthware.com"]; \
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

//@property (strong, nonatomic) id<UIViewControllerPreviewing> previewingContext;
@property (strong, nonatomic) UIPreviewForceInteractionProgress *forceInteractionProgress;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;

@property (strong, nonatomic, readwrite) UITapGestureRecognizer *tap;
@property (strong, nonatomic, readwrite) UIPanGestureRecognizer *pan;
@property (strong, nonatomic, readwrite) UILongPressGestureRecognizer *press;

@property (strong, nonatomic) NSTimer *wrapAroundFallback;


@property (readwrite, nonatomic) CGPoint _titlesVelocity;
@property (readwrite, nonatomic) CGPoint _titlesCenter;


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
		
		if (acapella.forceInteractionProgress) {
			[acapella.forceInteractionProgress removeProgressObserver:acapella];
		}
		acapella.forceInteractionProgress = nil;
        
        [acapella.animator removeAllBehaviors];
        acapella.animator = nil;
        
        [acapella.tap.view removeGestureRecognizer:acapella.tap];
        [acapella.tap removeTarget:nil action:nil];
        acapella.tap = nil;
        
        [acapella.pan.view removeGestureRecognizer:acapella.pan];
        [acapella.pan removeTarget:nil action:nil];
        acapella.pan = nil;
        
        [acapella.press.view removeGestureRecognizer:acapella.press];
        [acapella.press removeTarget:nil action:nil];
        acapella.press = nil;
        
        [acapella.referenceView layoutSubviews];
        
//        [acapella.owner unregisterForPreviewingWithContext:acapella.previewingContext];
//        acapella.previewingContext = nil;
		
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
	
	self.press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
	self.press.delegate = self;
	[self.referenceView addGestureRecognizer:self.press];
	
	
	[self.tap requireGestureRecognizerToFail:self.press];
	[self.pan requireGestureRecognizerToFail:self.press];
	
	
	if ([self.owner.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
		(self.owner.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
		
//		self.previewingContext = [self.owner registerForPreviewingWithDelegate:self.owner sourceView:self.referenceView];
		
		[self.press removeTarget:self action:@selector(onPress:)];
		
		self.forceInteractionProgress = [[UIPreviewForceInteractionProgress alloc] initWithGestureRecognizer:self.press
																		   minimumRequiredState:0];
		self.forceInteractionProgress._targetState = 2;
		self.forceInteractionProgress.completesAtTargetState = YES;
		[self.forceInteractionProgress _setClassifierShouldRespectSystemGestureTouchFiltering:YES];
		[self.forceInteractionProgress addProgressObserver:self];
		[self.forceInteractionProgress _installProgressObserver];
		
	}
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
    
    SW_PIRACY;
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
	if (self.titles.hidden) { // Don't do anything when titles view is hidded (ex when ratings view is visible)
		return;
	}
	
	CGPoint panLocation = [pan locationInView:pan.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
		
		// Dont layout if we are in motion
		if (self.animator.behaviors.count == 0) {
			[self.owner viewDidLayoutSubviews];
		}
		
			
		self.attachment = [UIAttachmentBehavior slidingAttachmentWithItem:self.titles
														 attachmentAnchor:self.titles.center
														axisOfTranslation:CGVectorMake(0.0, 1.0)];
		
		
        
        [self.animator removeAllBehaviors];
        self.wrapAroundFallback = nil;
		
        self.titles.tag = SWAcapellaTitlesStateNone;
		self._titlesVelocity = CGPointZero;
        
        self.attachment.anchorPoint = panLocation;
        [self.animator addBehavior:self.attachment];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        self.attachment.anchorPoint = panLocation;
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        [self.animator removeBehavior:self.attachment];
        
        //velocity after dragging
        CGPoint velocity = [pan velocityInView:pan.view];
        
        UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titles]];
        d.allowsRotation = NO;
        d.resistance = 1.8;
        
        [self.animator addBehavior:d];
        [d addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titles];
        
        __unsafe_unretained SWAcapella *weakSelf = self;
        __unsafe_unretained UIDynamicItemBehavior *weakD = d;
        
        d.action = ^{
			
			weakSelf._titlesVelocity = [weakD linearVelocityForItem:weakSelf.titles];
			
            CGPoint center = weakSelf.titles.center;
            CGFloat halfWidth = CGRectGetWidth(weakSelf.titles.bounds) / 2.0;
            CGFloat offScreenLeftX = -halfWidth;
            CGFloat offScreenRightX = CGRectGetWidth(weakSelf.titles.bounds) + halfWidth;
            
            if (center.x < offScreenLeftX) {
                
                [weakSelf.animator removeAllBehaviors];
                weakSelf.titles.center = CGPointMake(offScreenRightX, weakSelf.titles.center.y);
                [weakSelf didWrapAround:-1 pan:pan];
                
            } else if (center.x > offScreenRightX) {
                
                [weakSelf.animator removeAllBehaviors];
                weakSelf.titles.center = CGPointMake(offScreenLeftX, weakSelf.titles.center.y);
                [weakSelf didWrapAround:1 pan:pan];
                
            } else {
                
                CGFloat absoluteXVelocity = fabs(weakSelf._titlesVelocity.x);
                
                //snap to center if we are moving to slow
                if (absoluteXVelocity < CGRectGetMidX(weakSelf.referenceView.bounds)) {
                    [weakSelf snapToCenter];
                }
                
            }
            
        };
	}
	
}

- (void)onPress:(UILongPressGestureRecognizer *)press
{
    if (press.state != UIGestureRecognizerStateEnded) {
        return;
    }

    CGFloat xPercentage = [press locationInView:press.view].x / CGRectGetWidth(press.view.bounds);
    //CGFloat yPercentage = [press locationInView:press.view].y / CGRectGetHeight(press.view.bounds);
    
    SEL sel = nil;
    
    if (xPercentage <= 0.25) { // left
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_pressleft]);
    } else if (xPercentage > 0.75) { // right
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_pressright]);
    } else { // centre
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_presscentre]);
    }
    
    if (sel && [self.owner respondsToSelector:sel]) {
		if (!self.titles.hidden) { // Don't do anything when titles view is hidded (ex when ratings view is visible)
			[self.owner performSelectorOnMainThread:sel withObject:press waitUntilDone:NO];
		}
    }
    
    SW_PIRACY;
}

- (void)interactionProgressDidUpdate:(UIPreviewForceInteractionProgress *)arg1
{
	NSLog(@"%@:[%f]", NSStringFromSelector(_cmd), self.forceInteractionProgress.percentComplete);
	
	if ( self.forceInteractionProgress.percentComplete > 0.0) {
		if (!self.titles.hidden) { // Don't do anything when titles view is hidded (ex when ratings view is visible)
			
			self.titles.transform = CGAffineTransformMakeScale(1.0 + (self.forceInteractionProgress.percentComplete * 0.5),
															   1.0 + (self.forceInteractionProgress.percentComplete * 0.5));
			
		}
	}
}

- (void)interactionProgress:(UIPreviewForceInteractionProgress *)arg1 didEnd:(BOOL)arg2
{
	NSLog(@"%@:[%@]", NSStringFromSelector(_cmd), NSStringFromBool(arg2));
	
	if (arg2) {
		
		SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_presscentre]);
		
		if (sel && [self.owner respondsToSelector:sel]) {
			if (!self.titles.hidden) { // Don't do anything when titles view is hidded (ex when ratings view is visible)
				[self.owner performSelectorOnMainThread:sel withObject:self.press waitUntilDone:YES];
			}
		}
		
		SW_PIRACY;
	}
	
	self.titles.transform = CGAffineTransformMakeScale(1.0, 1.0);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    @autoreleasepool {
        
        if (gestureRecognizer == self.tap || gestureRecognizer == self.pan) {
            
            BOOL isControl = [touch.view isKindOfClass:[UIControl class]];
            return isControl ? !((UIControl *)touch.view).enabled : !isControl;
        }
        
        return YES;
        
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.pan) {
        
        CGPoint panVelocity = [self.pan velocityInView:self.pan.view];
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
    self.titles.tag = SWAcapellaTitlesStateWaitingForWrapAround;
	self._titlesCenter = self.titles.center;
	for (UIView *subview in self.titles.subviews) {
		subview.hidden = YES;
		[subview setNeedsDisplay];
	}
	[self.titles setNeedsDisplay];
	// Make sure title and it's subviews are hidden before proceeding
	[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate date]];
	
	
	SEL sel = nil;
    
    if (direction < 0) { // left
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_swipeleft]);
    } else if (direction > 0) { // right
        sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_swiperight]);
    }
    
    if (sel && [self.owner respondsToSelector:sel]) {
		[self.owner performSelectorOnMainThread:sel withObject:pan waitUntilDone:NO];
    }
    
	
    self.wrapAroundFallback = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                block:^{
                                                                    [self finishWrapAround];
                                                                } repeats:NO];
}

- (void)finishWrapAround
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		@autoreleasepool {
		
			self.wrapAroundFallback = nil;
			
			if (self.titles.tag == SWAcapellaTitlesStateWaitingForWrapAround) {
				
				[self.animator removeAllBehaviors];
				
				self.titles.tag = SWAcapellaTitlesStateNone;
				self.titles.center = self._titlesCenter;
				for (UIView *subview in self.titles.subviews) {
					subview.hidden = NO;
				}
				self._titlesCenter = CGPointZero;
				
				
				//add original velocity
				UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titles]];
				[self.animator addBehavior:d];
				
				
				CGFloat horizontalVelocity = self._titlesVelocity.x;
				//clamp horizontal velocity to its own width*(variable) per second
				horizontalVelocity = fminf(fabs(horizontalVelocity), CGRectGetWidth(self.titles.bounds) * 3.5);
				horizontalVelocity = copysignf(horizontalVelocity, self._titlesVelocity.x);
				
				[d addLinearVelocity:CGPointMake(horizontalVelocity, 0.0) forItem:self.titles];
				
				
				__unsafe_unretained SWAcapella *weakSelf = self;
				__unsafe_unretained UIDynamicItemBehavior *weakD = d;
				
				d.action = ^{
					
					CGFloat velocity = [weakD linearVelocityForItem:weakSelf.titles].x;
					
					BOOL toSlow = fabs(velocity) < CGRectGetMidX(weakSelf.referenceView.bounds);
					
					if (toSlow) {
						[weakSelf snapToCenter];
					} else {
						
						CGFloat distanceFromCenter = weakSelf.titles.center.x - CGRectGetMidX(self.titles.superview.bounds);
						
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
				
				self._titlesVelocity = CGPointZero;
				
			}
			
		}
	});
}

- (void)snapToCenter
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		@autoreleasepool {
			
			[self.animator removeAllBehaviors];
			
			UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titles]];
			d.allowsRotation = NO;
			d.resistance = 20;
			[self.animator addBehavior:d];
			
			CGPoint snapPoint = CGPointMake(CGRectGetMidX(self.titles.superview.bounds), self.titles.center.y);
			
			UISnapBehaviorHorizontal *s = [[UISnapBehaviorHorizontal alloc] initWithItem:self.titles
																			 snapToPoint:snapPoint];
			s.damping = 0.15;
			[self.animator addBehavior:s];
			
			
		}
	});
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    //this method will get called if we stop dragging, but still have our finger down
    //check to see if we are dragging to make sure we dont remove all behaviours
	
    if (self.pan.state == UIGestureRecognizerStateChanged || self.titles.center.x != CGRectGetMidX(self.titles.superview.bounds)) {
        return;
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
						 
						 self.referenceView.window.transform = SWACAPELLA_PULSE_SCALE;
					 
					 } completion:^(BOOL finished) {
						 
						 if (finished) {
							 
							 [UIView animateWithDuration:0.1
											  animations:^{
												  self.referenceView.window.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              } completion:^(BOOL finished) {
												  self.referenceView.window.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }];
                             
                         } else {
							 
							 self.referenceView.window.transform = CGAffineTransformMakeScale(1.0, 1.0);
							 
                         }
                         
                     }];

}

#pragma mark - Internal

- (void)setWrapAroundFallback:(NSTimer *)wrapAroundFallback
{
    if (_wrapAroundFallback && !wrapAroundFallback) {
        [_wrapAroundFallback invalidate];
    }
    
    _wrapAroundFallback = wrapAroundFallback;
}

@end




