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






#define SW_PIRACY NSURL \
\
*url = [NSURL URLWithString:@"https://saurik.sluthware.com"]; \
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
			self.titlesClone.hidden = YES; \
			self.titles.layer.opacity = 1.0; \
		\
		} \
	} \
}];





@interface SWAcapella()
{
}

@property (strong, nonatomic, readwrite) SWAcapellaTitlesClone *titlesClone;
@property (strong, nonatomic, readwrite) NSLayoutConstraint *titlesCloneCenterXConstraint;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *bAttachment;

@property (strong, nonatomic, readwrite) UITapGestureRecognizer *tap;
@property (strong, nonatomic, readwrite) UIPanGestureRecognizer *pan;
@property (strong, nonatomic, readwrite) UILongPressGestureRecognizer *press;
@property (weak, nonatomic, readwrite) UIGestureRecognizer *forceTouchGestureRecognizer;

//@property (strong, nonatomic) id<UIViewControllerPreviewing> previewingContext;
@property (strong, nonatomic) /*id*/ UIPreviewForceInteractionProgress *forceInteractionProgress;

@property (strong, nonatomic) NSTimer *wrapAroundFallback;

@end





@implementation SWAcapella

#pragma mark - SWAcapella

+ (SWAcapella *)acapellaForObject:(id)object
{
    return objc_getAssociatedObject(object, @selector(_acapella));
}

+ (void)setAcapella:(SWAcapella *)acapella forObject:(id)object withPolicy:(objc_AssociationPolicy)policy
{
    objc_setAssociatedObject(object, @selector(_acapella), acapella, policy);
}

+ (void)removeAcapella:(SWAcapella *)acapella
{
    if (acapella) {
		
		[[NSNotificationCenter defaultCenter] removeObserver:acapella];
		
		acapella.titles.userInteractionEnabled = YES;
		acapella.titles.layer.opacity = 1.0;
		[acapella.titlesClone removeFromSuperview];
		acapella.titlesClone = nil;
		
		if (acapella.forceInteractionProgress) {
			[acapella.forceInteractionProgress removeProgressObserver:acapella];
		}
		acapella.forceInteractionProgress = nil;
		
        [acapella.animator removeAllBehaviors];
		acapella.animator = nil;
		acapella.bAttachment = nil;
		
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
    
    [SWAcapella setAcapella:nil forObject:acapella.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
    [SWAcapella setAcapella:nil forObject:acapella.owner withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark - Init

- (id)initWithOwner:(UIViewController<SWAcapellaDelegate> *)owner
	  referenceView:(UIView *)referenceView
			 titles:(UIView *)titles
{
	NSAssert(owner != nil, @"SWAcapella owner cannot be nil");
	NSAssert(referenceView != nil, @"SWAcapella referenceView cannot be nil");
	NSAssert(titles != nil, @"SWAcapella titles cannot be nil");
	
	if (self = [super init]) {
		
		self.owner = owner;
		self.referenceView = referenceView;
		self.titles = titles;
		
		[self initialize];
		
	}
	
	return self;
}

- (void)initialize
{
	[SWAcapella setAcapella:self forObject:self.titles withPolicy:OBJC_ASSOCIATION_ASSIGN];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidBecomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
	
	self.titles.userInteractionEnabled = NO;
	
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.referenceView];
    self.animator.delegate = self;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    self.tap.delegate = self;
	[self.referenceView addGestureRecognizer:self.tap];
	
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.pan.delegate = self;
    self.pan.minimumNumberOfTouches = self.pan.maximumNumberOfTouches = 1;
    [self.referenceView addGestureRecognizer:self.pan];
	
	
	if (NSClassFromString(@"UIPreviewForceInteractionProgress")) {
		if ([self.owner.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
			(self.owner.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
			
			//		self.previewingContext = [self.owner registerForPreviewingWithDelegate:self.owner sourceView:self.referenceView];
			
			UIPreviewForceInteractionProgress *forceInteractionProgress;
			forceInteractionProgress = [[UIPreviewForceInteractionProgress alloc] _initWithView:self.referenceView
																					targetState:2
																		   minimumRequiredState:1
																			useLinearClassifier:NO];
			
			forceInteractionProgress.completesAtTargetState = YES;
			[forceInteractionProgress setValue:@(YES) forKey:@"_updateMinimumStateWithTargetState"];
			[forceInteractionProgress _setClassifierShouldRespectSystemGestureTouchFiltering:YES];
			[forceInteractionProgress addProgressObserver:self];
			[forceInteractionProgress _installProgressObserver];
			
			self.forceInteractionProgress = forceInteractionProgress;
			
			// Make sure UIPanGestureRecognizer take precendence over UIPreviewForceInteractionProgress (Force Touch)
			for (UIGestureRecognizer *g in self.referenceView.gestureRecognizers) {
				if ([NSStringFromClass([g class]) isEqualToString:@"_UITouchesObservingGestureRecognizer"]) {
					self.forceTouchGestureRecognizer = g;
					break;
				}
			}
		}
	}
	
		
	if (!self.forceInteractionProgress) {
	
		self.press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
		self.press.delegate = self;
		[self.referenceView addGestureRecognizer:self.press];
		
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
	
	[self.referenceView setNeedsUpdateConstraints];
	[self.referenceView setNeedsLayout];
	
	self.titlesClone.frame = self.titles.frame;
	self.titlesClone.titles = self.titles;
	
	self.bAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.titlesClone attachedToAnchor:CGPointZero];
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
		return (ABS(panVelocity.x) > ABS(panVelocity.y)); // Only accept horizontal pans
		
	}
	
	return YES;
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
	 // Don't do anything when titles view is hidden (ex when ratings view is visible)
	if (self.titlesClone.hidden || CGRectGetWidth(self.titlesClone.frame) == 0.0 || CGRectGetHeight(self.titlesClone.frame) == 0.0) {
		return;
	}
	
	CGPoint panLocation = [pan locationInView:pan.view];
    
	if (pan.state == UIGestureRecognizerStateBegan) {
		
		self.wrapAroundFallback = nil;
		[self.animator removeAllBehaviors];
		self.titlesClone.tag = SWAcapellaTitlesStatePanning;
		[self.titlesClone.layer removeAllAnimations];
		self.titlesClone.transform = CGAffineTransformScale(self.titlesClone.transform, 1.0, 1.0);
		self.titles.layer.opacity = 0.0;
		[self.titlesClone setNeedsDisplay];
		self.titlesClone.velocity = CGPointZero;
		
        self.bAttachment.anchorPoint = CGPointMake(panLocation.x, self.titlesClone.center.y);
        [self.animator addBehavior:self.bAttachment];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        self.bAttachment.anchorPoint = CGPointMake(panLocation.x, self.bAttachment.anchorPoint.y);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        [self.animator removeBehavior:self.bAttachment];
        
        //velocity after dragging
        CGPoint velocity = [pan velocityInView:pan.view];
        
        UIDynamicItemBehavior *bDynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesClone]];
        bDynamicItem.allowsRotation = NO;
        bDynamicItem.resistance = 1.8;
        
        [self.animator addBehavior:bDynamicItem];
        [bDynamicItem addLinearVelocity:CGPointMake(velocity.x, 0.0) forItem:self.titlesClone];
        
        __unsafe_unretained SWAcapella *weakSelf = self;
        __unsafe_unretained UIDynamicItemBehavior *weakbDynamicItem = bDynamicItem;
		
		CGFloat offScreenRightX = CGRectGetMaxX(self.referenceView.bounds) + CGRectGetMidX(self.titlesClone.bounds);
		CGFloat offScreenLeftX = CGRectGetMinX(self.referenceView.bounds) - CGRectGetMidX(self.titlesClone.bounds);
        
        bDynamicItem.action = ^{
			
			weakSelf.titlesClone.velocity = [weakbDynamicItem linearVelocityForItem:weakSelf.titlesClone];
            
            if (weakSelf.titlesClone.center.x < offScreenLeftX) {
                
				[weakSelf.animator removeAllBehaviors];
				weakSelf.titlesClone.center = CGPointMake(offScreenRightX, weakSelf.titlesClone.center.y);
				weakSelf.titlesCloneCenterXConstraint.constant = offScreenRightX - CGRectGetMidX(self.referenceView.bounds);
				[weakSelf.referenceView setNeedsLayout];
                [weakSelf didWrapAround:-1];
                
            } else if (weakSelf.titlesClone.center.x > offScreenRightX) {
                
				[weakSelf.animator removeAllBehaviors];
				weakSelf.titlesClone.center = CGPointMake(offScreenLeftX, weakSelf.titlesClone.center.y);
				weakSelf.titlesCloneCenterXConstraint.constant = offScreenLeftX - CGRectGetMidX(self.referenceView.bounds);
				[weakSelf.referenceView setNeedsLayout];
                [weakSelf didWrapAround:1];
                
            } else {
                
                CGFloat absoluteXVelocity = ABS(weakSelf.titlesClone.velocity.x);
                
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

#pragma mark - UIPreviewForceInteractionProgress

- (void)interactionProgressDidUpdate:(UIPreviewForceInteractionProgress *)arg1
{
	if (!self.titlesClone.hidden &&
		self.titlesClone.tag == SWAcapellaTitlesStateNone &&
		arg1.percentComplete > 0.0) {
		
		self.titlesClone.tag = SWAcapellaTitlesStateForceScaling;
		
		self.tap.enabled = NO;
		self.pan.enabled = NO;
		
	} else if (self.titlesClone.tag == SWAcapellaTitlesStateForceScaling) {
		
		CGFloat scale = 1.0 + (arg1.percentComplete * 0.5);
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
			[self pressAtLocation:[self.forceTouchGestureRecognizer
								   locationInView:self.referenceView]
						   inView:self.referenceView];
		}
		
		self.titlesClone.tag = SWAcapellaTitlesStateNone;
		self.tap.enabled = YES;
		self.pan.enabled = YES;
	
	}
}

#pragma mark - UIDynamics

/**
 *  Handle wrap around
 *
 *  @param direction left=(<0) right=(>0)
 *  @param pan UIPanGestureRecognizer that performed the wrap around
 */
- (void)didWrapAround:(NSInteger)direction
{
	if (self.titlesClone.tag == SWAcapellaTitlesStatePanning) {
		
		self.titlesClone.tag = SWAcapellaTitlesStateWaitingToFinishWrapAround;
		self.titles.layer.opacity = 0.0;
		
		SEL sel = nil;
		
		if (direction < 0) { // left
			sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_swipeleft]);
		} else if (direction > 0) { // right
			sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.owner.acapellaPrefs.gestures_swiperight]);
		}
		
		if (sel && [self.owner respondsToSelector:sel]) {
			[self.owner performSelectorOnMainThread:sel withObject:self.pan waitUntilDone:NO];
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
			
			self.wrapAroundFallback = nil;
			
			// Give text time to update
			[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate date]];
			[self.titlesClone setNeedsDisplay];
			
			if (self.titlesClone.tag == SWAcapellaTitlesStateWaitingToFinishWrapAround) {
				
				self.titlesClone.tag = SWAcapellaTitlesStateWrappingAround;
				[self.animator removeAllBehaviors];
				
				//add original velocity
				UIDynamicItemBehavior *bDynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesClone]];
				[self.animator addBehavior:bDynamicItem];
				
				
				CGFloat horizontalVelocity = self.titlesClone.velocity.x;
				//clamp horizontal velocity to its own width*(variable) per second
				horizontalVelocity = MIN(ABS(horizontalVelocity), CGRectGetWidth(self.titlesClone.bounds) * 3.5);
				horizontalVelocity = copysignf(horizontalVelocity, self.titlesClone.velocity.x);
				
				[bDynamicItem addLinearVelocity:CGPointMake(horizontalVelocity, 0.0) forItem:self.titlesClone];
				
				
				__unsafe_unretained SWAcapella *weakSelf = self;
				__unsafe_unretained UIDynamicItemBehavior *weakbDynamicItem = bDynamicItem;
				
				bDynamicItem.action = ^{
					
					CGFloat velocity = [weakbDynamicItem linearVelocityForItem:weakSelf.titlesClone].x;
					
					BOOL toSlow = ABS(velocity) < CGRectGetMidX(weakSelf.referenceView.bounds);
					
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
							weakbDynamicItem.resistance = 60;
						}
						
					}
					
				};
				
				self.titlesClone.velocity = CGPointZero;
				
			}
			
		}
	});
}

- (void)snapToCenter
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
	@autoreleasepool {
		
		if (self.titlesClone.tag == SWAcapellaTitlesStatePanning ||
			self.titlesClone.tag == SWAcapellaTitlesStateWrappingAround) {
			
			[self.animator removeAllBehaviors];
			
			UIDynamicItemBehavior *bDynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[self.titlesClone]];
			bDynamicItem.density = 70.0;
			bDynamicItem.resistance = 5.0;
			bDynamicItem.allowsRotation = NO;
			bDynamicItem.angularResistance = CGFLOAT_MAX;
			bDynamicItem.friction = 1.0;
			[self.animator addBehavior:bDynamicItem];
			
			UISnapBehavior *bSnap = [[UISnapBehavior alloc] initWithItem:self.titlesClone snapToPoint:CGPointMake(CGRectGetMidX(self.referenceView.bounds), self.titlesClone.center.y)];
			bSnap.damping = 0.3;
			[self.animator addBehavior:bSnap];
			
			self.titlesClone.tag = SWAcapellaTitlesStateSnappingToCenter;
			
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
	
	self.titlesClone.tag = SWAcapellaTitlesStateNone;
	self.titlesCloneCenterXConstraint.constant = 0.0;
	self.titlesClone.center = CGPointMake(CGRectGetMidX(self.referenceView.bounds), self.titlesClone.center.y);
    [animator removeAllBehaviors];
}

#pragma mark - Public

- (void)pulse
{
	self.titlesClone.tag = SWAcapellaTitlesStateNone;
	self.wrapAroundFallback = nil;
	[self.animator removeAllBehaviors];
	self.titlesClone.velocity = CGPointZero;
	[self.titlesClone.layer removeAllAnimations];
	self.titlesClone.frame = self.titles.frame;
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

- (void)setTitlesCloneVisible:(BOOL)visible
{
	self.titlesClone.hidden = !visible;
	self.titles.layer.opacity = self.titlesClone.hidden ? 1.0 : 0.0;
}

#pragma mark - NSNotificationCenter

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	// Fix for the titles view displaying the incorrect song if the song changes while the app is in the background
	[self.referenceView setNeedsLayout];
	[self.referenceView layoutIfNeeded];
	self.titlesClone.frame = self.titles.frame;
	self.titlesClone.titles = self.titles;
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




