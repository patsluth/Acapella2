//
//  SWAcapellaDebug.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "libsw/libSluthware/libSluthware.h"

#import "UIKit/UIPreviewForceInteractionProgress.h"





//%hook UIPreviewForceInteractionProgress
//
//- (id)_initWithObservable:(id)arg1 targetState:(int)arg2 minimumRequiredState:(int)arg3
//{
//	id orig = %orig(arg1, arg2, arg3);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"arg3:[%@]", @(arg3));
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (id)_initWithObservable:(id)arg1 targetState:(int)arg2 minimumRequiredState:(int)arg3 useLinearClassifier:(BOOL)arg4
//{
//	id orig = %orig(arg1, arg2, arg3, arg4);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"arg3:[%@]", @(arg3));
//	NSLog(@"arg4:[%@]", @(arg3));
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (id)_initWithView:(id)arg1 targetState:(int)arg2 minimumRequiredState:(int)arg3 useLinearClassifier:(BOOL)arg4
//{
//	id orig = %orig(arg1, arg2, arg3, arg4);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"arg3:[%@]", @(arg3));
//	NSLog(@"arg4:[%@]", @(arg4));
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (id)initWithView:(id)arg1 targetState:(int)arg2
//{
//	id orig = %orig(arg1, arg2);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (id)initWithView:(id)arg1 targetState:(int)arg2 minimumRequiredState:(int)arg3
//{
//	id orig = %orig(arg1, arg2, arg3);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"arg3:[%@]", @(arg3));
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (id)initWithGestureRecognizer:(id)arg1 minimumRequiredState:(long long)arg2
//{
//	id orig = %orig(arg1, arg2);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (void)_forceLevelClassifier:(id)arg1 didUpdateProgress:(double)arg2 toForceLevel:(long long)arg3
//{
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	NSLog(@"arg3:[%@]", @(arg3));
//	LOG_METHOD_END
//	
//	%orig(arg1, arg2, arg3);
//}
//
//- (void)_forceLevelClassifier:(id)arg1 currentForceLevelDidChange:(int)arg2
//{
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	
//	
//	
//	LOG_METHOD_END
//	
//	%orig(arg1, arg2);
//}
//
//- (void)_forceLevelClassifierDidReset:(id)arg1
//{
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	LOG_METHOD_END
//	
//	%orig(arg1);
//}
//
//%end





//%hook UIPreviewInteractionController
//
//- (id)init
//{
//	id orig = %orig();
//	
//	LOG_METHOD_START
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (void)initGestureRecognizers
//{
//	%orig();
//	
//	LOG_METHOD_START
//	LOG_METHOD_END
//}
//
//- (void)interactionProgressDidUpdate:(id)arg1
//{
//	%orig();
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	LOG_METHOD_END
//}
//
//- (BOOL)_previewingIsPossibleForView:(id)arg1
//{
//	BOOL orig = %orig(arg1);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"retunVal:[%@]", NSStringFromBool(orig));
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (BOOL)startInteractivePreviewAtLocation:(CGPoint)arg1 inView:(id)arg2
//{
//	BOOL orig = %orig(arg1, arg2);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", NSStringFromCGPoint(arg1));
//	NSLog(@"arg2:[%@]", arg2);
//	NSLog(@"retunVal:[%@]", NSStringFromBool(orig));
//	LOG_METHOD_END
//	
//	return orig;
//
//}
//
//- (BOOL)startInteractivePreviewWithGestureRecognizer:(id)arg1
//{
//	BOOL orig = %orig(arg1);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"retunVal:[%@]", NSStringFromBool(orig));
//	LOG_METHOD_END
//	
//	return orig;
//}
//
//- (void)setTouchSelectionWorkaroundSnapshotView:(UIView *)arg1
//{
//	%orig();
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	LOG_METHOD_END
//}
//
//- (id)_insertTouchSelectionWorkaroundSnapshotViewToView:(id)arg1 presentationController:(id)arg2
//{
//	id orig = %orig(arg1, arg2);
//	
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", arg2);
//	NSLog(@"retunVal:[%@]", orig);
//	LOG_METHOD_END
//	
//	return nil;
//}
//
//%end





// Disable snapshot effects
//%hook UIPreviewPresentationController
//
//+ (BOOL)_shouldApplyVisualEffectsToPresentingView
//{
//	LOG_METHOD_START
//	return NO;
//}
//
//- (BOOL)_shouldDisableInteractionDuringTransitions
//{
//	LOG_METHOD_START
//	return YES;
//}
//
//- (BOOL)_shouldSavePresentedViewControllerForStateRestoration
//{
//	LOG_METHOD_START
//	return NO;
//}
//
//- (BOOL)_sourceViewSnapshotAndScaleTransformSuppressed
//{
//	LOG_METHOD_START
//	return YES;
//}
//
//%end





//%hook _UIPreviewTransitionController
//
//+(void)performCommitTransitionWithDelegate:(id)arg1
//forViewController:(id)arg2
//previewViewController:(id)arg3
//previewInteractionController:(id)arg4
//completion:(/*^block*/id)arg5
//{
//	
//}
//
//%end





//%hook MusicNowPlayingViewController
//
//- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2
//{
//	LOG_METHOD_START
//	NSLog(@"arg1:[%@]", arg1);
//	NSLog(@"arg2:[%@]", @(arg2));
//	LOG_METHOD_END
//	
//    %orig(arg1, arg2);
//}
//
//%end




