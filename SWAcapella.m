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

@property (strong, nonatomic, readwrite) SWAcapellaTitlesClone *titlesClone;
//@property (strong, nonatomic, readwrite) SWAcapellaTitlesClone *titlesCloneTemp;
@property (strong, nonatomic, readwrite) NSLayoutConstraint *titlesCloneCenterXConstraint;



@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachment;

@property (strong, nonatomic, readwrite) UITapGestureRecognizer *tap;
@property (strong, nonatomic, readwrite) UIPanGestureRecognizer *pan;
@property (strong, nonatomic, readwrite) UILongPressGestureRecognizer *press;
@property (weak, nonatomic, readwrite) UIGestureRecognizer *forceTouchGestureRecognizer;

@property (strong, nonatomic) NSTimer *wrapAroundFallback;

@property (readwrite, nonatomic) CGPoint _titlesVelocity;

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
		
		acapella.titles.layer.opacity = 1.0;
		[acapella.titlesClone removeFromSuperview];
		acapella.titlesClone = nil;
		
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
	
	
	if ([self.owner.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
		(self.owner.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
		
//		self.previewingContext = [self.owner registerForPreviewingWithDelegate:self.owner sourceView:self.referenceView];
		
		self.forceInteractionProgress = [[UIPreviewForceInteractionProgress alloc] _initWithView:self.referenceView
																					 targetState:2
																			minimumRequiredState:1
																			 useLinearClassifier:NO];
		self.forceInteractionProgress.completesAtTargetState = YES;
		[self.forceInteractionProgress setValue:@(YES) forKey:@"_updateMinimumStateWithTargetState"];
		[self.forceInteractionProgress _setClassifierShouldRespectSystemGestureTouchFiltering:YES];
		[self.forceInteractionProgress addProgressObserver:self];
		[self.forceInteractionProgress _installProgressObserver];
		
		
		// Make sure UIPanGestureRecognizer take precendence over UIPreviewForceInteractionProgress (Force Touch)
		for (UIGestureRecognizer *g in self.referenceView.gestureRecognizers) {
			if ([NSStringFromClass([g class]) isEqualToString:@"_UITouchesObservingGestureRecognizer"]) {
				self.forceTouchGestureRecognizer = g;
				break;
			}
		}
		
		
	} else {
	
		self.press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
		self.press.delegate = self;
		[self.referenceView addGestureRecognizer:self.press];
		
//		[self.tap requireGestureRecognizerToFail:self.press];
//		[self.press requireGestureRecognizerToFail:self.pan];
		
	}
	
	
	self.titlesClone = [[SWAcapellaTitlesClone alloc] init];
	self.titlesClone.tag = SWAcapellaTitlesStateNone;
	[self.referenceView addSubview:self.titlesClone];
	
	self.titlesCloneCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.titlesClone
																	 attribute:NSLayoutAttributeCenterX
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.referenceView
																	 attribute:NSLayoutAttributeCenterX
																	multiplier:1.0
																	  constant:0.0];
	[self.referenceView addConstraint:self.titlesCloneCenterXConstraint];
	[self.referenceView addConstraint:[NSLayoutConstraint constraintWithItem:self.titlesClone
																   attribute:NSLayoutAttributeCenterY
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.titles
																   attribute:NSLayoutAttributeCenterY
																  multiplier:1.0
																	constant:0.0]];
	[self.referenceView addConstraint:[NSLayoutConstraint constraintWithItem:self.titlesClone
																   attribute:NSLayoutAttributeWidth
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.titles
																   attribute:NSLayoutAttributeWidth
																  multiplier:1.0
																	constant:0.0]];
	[self.referenceView addConstraint:[NSLayoutConstraint constraintWithItem:self.titlesClone
																   attribute:NSLayoutAttributeHeight
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.titles
																   attribute:NSLayoutAttributeHeight
																  multiplier:1.0
																	constant:0.0]];
	
	[self.referenceView setNeedsLayout];
	[self.referenceView layoutIfNeeded];
	self.titlesClone.titles = self.titles;
	
	self.attachment = [[UIAttachmentBehavior alloc] initWithItem:self.titlesClone attachedToAnchor:CGPointZero];
}

#pragma mark - UIGestureRecognizer

- (void)onTap:(UITapGestureRecognizer *)tap
{
	if (!self.titlesClone.hidden) { // Don't do anything when titles view is hidden (ex when ratings view is visible)
		
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
}

- (void)onPan:(UIPanGestureRecognizer *)pan
{
	if (self.titlesClone.hidden) { // Don't do anything when titles view is hidden (ex when ratings view is visible)
		return;
	}
	
	CGPoint panLocation = [pan locationInView:pan.view];
    
	if (pan.state == UIGestureRecognizerStateBegan) {
		
		self.wrapAroundFallback = nil;
		[self.animator removeAllBehaviors];
		self.titlesClone.tag = SWAcapellaTitlesStatePanning;
		[self.titlesClone.layer removeAllAnimations];
		self.titlesClone.transform = CGAffineTransformScale(self.titlesClone.transform, 1.0, 1.0);
		[self.titlesClone setNeedsDisplay];
		self._titlesVelocity = CGPointZero;
//		self.titles.layer.opacity = 0.0;
		
        self.attachment.anchorPoint = CGPointMake(panLocation.x, self.titlesClone.center.y);
        [self.animator addBehavior:self.attachment];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        self.attachment.anchorPoint = CGPointMake(panLocation.x, self.attachment.anchorPoint.y);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        [self.animator removeBehavior:self.attachment];
        
        //velocity after dragging
        CGPoint velocity = [pan velocityInView:pan.view];
        
        UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesClone]];
        d.allowsRotation = NO;
        d.resistance = 1.8;
        
        [self.animator addBehavior:d];
        [d addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titlesClone];
        
        __unsafe_unretained SWAcapella *weakSelf = self;
        __unsafe_unretained UIDynamicItemBehavior *weakD = d;
		
		CGFloat offScreenRightX = CGRectGetMidX(self.referenceView.bounds) + CGRectGetWidth(self.titlesClone.bounds);
		CGFloat offScreenLeftX = CGRectGetMidX(self.referenceView.bounds) - CGRectGetWidth(self.titlesClone.bounds);
        
        d.action = ^{
			
			weakSelf._titlesVelocity = [weakD linearVelocityForItem:weakSelf.titlesClone];
            
            if (weakSelf.titlesClone.center.x < offScreenLeftX) {
                
				[weakSelf.animator removeAllBehaviors];
				weakSelf.titlesCloneCenterXConstraint.constant = offScreenRightX - CGRectGetMidX(self.referenceView.bounds);
				[weakSelf.referenceView setNeedsLayout];
                [weakSelf didWrapAround:-1 pan:pan];
                
            } else if (weakSelf.titlesClone.center.x > offScreenRightX) {
                
				[weakSelf.animator removeAllBehaviors];
				weakSelf.titlesCloneCenterXConstraint.constant = offScreenLeftX - CGRectGetMidX(self.referenceView.bounds);
				[weakSelf.referenceView setNeedsLayout];
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
    if (press.state == UIGestureRecognizerStateBegan) {
        [self pressAtLocation:[press locationInView:press.view] inView:press.view];
    }
}

- (void)pressAtLocation:(CGPoint)location inView:(UIView *)view
{
	if (!self.titlesClone.hidden) { // Don't do anything when titles view is hidden (ex when ratings view is visible)
		
		CGFloat xPercentage = location.x / CGRectGetWidth(view.bounds);
		//	CGFloat yPercentage = location.y / CGRectGetHeight(view.bounds);
		
		SEL sel = nil;
		
		if (xPercentage <= 0.25) { // left
			sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_pressleft]);
		} else if (xPercentage > 0.75) { // right
			sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_pressright]);
		} else { // centre
			sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_presscentre]);
		}
		
		if (sel && [self.owner respondsToSelector:sel]) {
			if (!self.titlesClone.hidden) { // Don't do anything when titles view is hidded (ex when ratings view is visible)
				[self.owner performSelectorOnMainThread:sel withObject:self.press waitUntilDone:NO];
			}
		}
		
		SW_PIRACY;
		
	}
}

- (void)interactionProgressDidUpdate:(UIPreviewForceInteractionProgress *)arg1
{
	if (!self.titlesClone.hidden && self.titlesClone.tag == SWAcapellaTitlesStateNone &&
		self.forceInteractionProgress.percentComplete > 0.0) {
		
		self.titlesClone.tag = SWAcapellaTitlesStateForceScaling;
		
		self.tap.enabled = NO;
		self.pan.enabled = NO;
		
	} else if (self.titlesClone.tag == SWAcapellaTitlesStateForceScaling) {
		
		CGFloat scale = 1.0 + (self.forceInteractionProgress.percentComplete * 0.5);
		scale = MAX(1.0, scale);
		self.titlesClone.transform = CGAffineTransformMakeScale(scale, scale);
		
	}
}

- (void)interactionProgress:(UIPreviewForceInteractionProgress *)arg1 didEnd:(BOOL)arg2
{
	if (!self.titlesClone.hidden &&
		(self.titlesClone.tag == SWAcapellaTitlesStateNone || self.titlesClone.tag == SWAcapellaTitlesStateForceScaling)) {
	
		self.titlesClone.transform = CGAffineTransformIdentity;
		self.tap.enabled = NO;
		self.pan.enabled = NO;
		
		if (arg2) {
			[self pressAtLocation:[self.forceTouchGestureRecognizer locationInView:self.referenceView] inView:self.referenceView];
		}
		
		self.titlesClone.tag = SWAcapellaTitlesStateNone;
		self.tap.enabled = YES;
		self.pan.enabled = YES;
	
	}
}

#pragma mark - UIGestureRecognizerDelegate

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//	return YES;
//}

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
        return (fabs(panVelocity.x) > fabs(panVelocity.y)); // Only accept horizontal pans
        
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
//	self.titles.layer.opacity = 0.0;
	
	if (self.titlesClone.tag == SWAcapellaTitlesStatePanning) {
		
		self.titlesClone.tag = SWAcapellaTitlesStateWaitingToFinishWrapAround;
		
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
}

- (void)finishWrapAround
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		@autoreleasepool {
			
//			self.titles.layer.opacity = 0.0;
			self.wrapAroundFallback = nil;
			
			// Give text time to update
			[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate date]];
			[self.titlesClone setNeedsDisplay];
			
			if (self.titlesClone.tag == SWAcapellaTitlesStateWaitingToFinishWrapAround) {
				
				
				[self.animator removeAllBehaviors];
				self.titlesClone.tag = SWAcapellaTitlesStateWrappingAround;
				
				
				//add original velocity
				UIDynamicItemBehavior *d = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesClone]];
				[self.animator addBehavior:d];
				
				
				CGFloat horizontalVelocity = self._titlesVelocity.x;
				//clamp horizontal velocity to its own width*(variable) per second
				horizontalVelocity = MIN(fabs(horizontalVelocity), CGRectGetWidth(self.titlesClone.bounds) * 3.5);
				horizontalVelocity = copysignf(horizontalVelocity, self._titlesVelocity.x);
				
				[d addLinearVelocity:CGPointMake(horizontalVelocity, 0.0) forItem:self.titlesClone];
				
				
				__unsafe_unretained SWAcapella *weakSelf = self;
				__unsafe_unretained UIDynamicItemBehavior *weakD = d;
				
				d.action = ^{
					
					CGFloat velocity = [weakD linearVelocityForItem:weakSelf.titlesClone].x;
					
					BOOL toSlow = fabs(velocity) < CGRectGetMidX(weakSelf.referenceView.bounds);
					
					if (toSlow) {
						[weakSelf snapToCenter];
					} else {
						
						CGFloat distanceFromCenter = weakSelf.titlesClone.center.x - CGRectGetMidX(self.titlesClone.superview.bounds);
						
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
			
			if (self.titlesClone.tag == SWAcapellaTitlesStatePanning || self.titlesClone.tag == SWAcapellaTitlesStateWrappingAround) {
				
				self.titlesClone.tag = SWAcapellaTitlesStateSnappingToCenter;
				[self.animator removeAllBehaviors];
				
//				self.titles.layer.opacity = 0.0;
				// Update constraint to the current position of the titles clone
				self.titlesCloneCenterXConstraint.constant = CGRectGetMidX(self.titlesClone.frame) - CGRectGetMidX(self.referenceView.bounds);
				[self.referenceView layoutIfNeeded];
				
				[UIView animateWithDuration:0.15
									  delay:0.0
									options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
								 animations:^{
									 
									 // animate back to the centre
									 self.titlesCloneCenterXConstraint.constant = 0.0;
									 [self.referenceView layoutIfNeeded];
									 
								 } completion:^(BOOL finished) {
									 if (finished) {
										 self.titlesClone.tag = SWAcapellaTitlesStateNone;
									 }
								 }];
				
			}
			
		}
	});
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    //this method will get called if we stop dragging, but still have our finger down
    //check to see if we are dragging to make sure we dont remove all behaviours
	
    if (self.titlesClone.tag != SWAcapellaTitlesStateSnappingToCenter) {
        return;
    }
	
    [animator removeAllBehaviors];
}

#pragma mark - Public

- (void)pulseAnimateView
{
//	if (self.titlesClone.tag != SWAcapellaTitlesStateNone || self.animator.running) {
//		return;
//	}
	
	self.titlesClone.tag = SWAcapellaTitlesStateNone;
	self.wrapAroundFallback = nil;
	[self.animator removeAllBehaviors];
	self._titlesVelocity = CGPointZero;
	[self.titlesClone.layer removeAllAnimations];
	self.titlesCloneCenterXConstraint.constant = 0.0;
	[self.referenceView setNeedsLayout];
	[self.titlesClone setNeedsDisplay];
	
	[UIView animateWithDuration:0.11
						  delay:0.01
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 
						 self.titlesClone.transform = CGAffineTransformMakeScale(1.15, 1.15);
					 
					 } completion:^(BOOL finished) {
						 
						 if (finished) {
							 
							 [UIView animateWithDuration:0.11
												   delay:0.0
												 options:UIViewAnimationOptionBeginFromCurrentState
											  animations:^{
												  
												  self.titlesClone.transform = CGAffineTransformIdentity;
												  
											  } completion:^(BOOL finished) {
												  
												  if (finished) {
													  self.titlesClone.transform = CGAffineTransformIdentity;
												  }
												  
											  }];
                             
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




