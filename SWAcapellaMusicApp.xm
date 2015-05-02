
#import <Social/Social.h>

#import <AcapellaKit/AcapellaKit.h>
#import "libSluthware.h"
#import "NSTimer+SW.h"
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"
#import "SWAcapella.h"

#import <MediaRemote/MediaRemote.h>

#import "MusicNowPlayingViewController.h"
#import "MPPlaybackControlsView.h"
#import "MusicNowPlayingPlaybackControlsView.h"
#import "MPAVController.h"
#import "MPAVItem.h"
#import "MPDetailSlider.h"
#import "MPVolumeSlider.h"

#import "substrate.h"
#import <objc/runtime.h>





#pragma mark - MusicNowPlayingViewController

static SWAcapellaBase *_acapella;

static NSDictionary *_previousNowPlayingInfo;





@interface MusicNowPlayingViewController()
{
}

@property (strong, nonatomic) SWAcapellaBase *acapella;

@property (strong, nonatomic) NSDictionary *previousNowPlayingInfo;

- (void)appDidBecomeActive:(NSNotification *)notification;

- (void)startRatingShouldHideTimer;
- (void)hideRatingControlWithTimer;

- (UIView *)playbackControlsView;
- (MPAVController *)player;
- (UIView *)progressControl;
- (UIView *)transportControls;
- (UIView *)volumeSlider;
- (UIView *)ratingControl;
- (UIView *)titlesView;
- (UIView *)repeatButton;
- (UIView *)geniusButton;
- (UIButton *)createButton;
- (UIView *)shuffleButton;
- (UIView *)artworkView;
- (MPAVItem *)mpavItem;
- (UIButton *)likeOrBanButton;

@end
//
//
//
//
//
%hook MusicNowPlayingViewController
//
//#pragma mark - Helper
//
%new
- (UIView *)playbackControlsView
{
    return MSHookIvar<UIView *>(self, "_playbackControlsView");
}

%new
- (MPAVController *)player
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<MPAVController *>([self playbackControlsView], "_player");
}

%new
- (UIView *)progressControl
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self playbackControlsView], "_progressControl");
}

%new
- (UIView *)transportControls
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self playbackControlsView], "_transportControls");
}

%new
- (UIView *)volumeSlider
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self playbackControlsView], "_volumeSlider");
}

%new
- (UIView *)ratingControl
{
    return MSHookIvar<UIView *>(self, "_ratingControl");
}

%new
- (UIView *)titlesView
{
    return MSHookIvar<UIView *>(self, "_titlesView");
}

%new
- (UIView *)repeatButton
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self playbackControlsView], "_repeatButton");
}

%new
- (UIView *)geniusButton
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self playbackControlsView], "_geniusButton");
}

%new
- (UIButton *)createButton
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIButton *>([self playbackControlsView], "_createButton");
}

%new
- (UIView *)shuffleButton
{
    if (![self playbackControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self playbackControlsView], "_shuffleButton");
}

%new
- (UIView *)artworkView
{
    return MSHookIvar<UIView *>(self, "_contentView");
}

%new
- (MPAVItem *)mpavItem
{
    return MSHookIvar<MPAVItem *>(self, "_item");
}

%new
- (UIButton *)likeOrBanButton
{
    if (![self transportControls]){
        return nil;
    }
    
    return MSHookIvar<UIButton *>([self transportControls], "_likeOrBanButton");
}

%new
- (SWAcapellaBase *)acapella
{
    SWAcapellaBase *a = objc_getAssociatedObject(self, &_acapella);
    
    if (!a){
        
        UIView *mediaControlsView = [self playbackControlsView];
        
        if (mediaControlsView) {
            
            //make sure views are all setup for constraints
            if (!([self progressControl] &&
                  [self volumeSlider])){
                return nil;
            }
            
            [self setAcapella:[[%c(SWAcapellaBase) alloc] init]];
            a = objc_getAssociatedObject(self, &_acapella);
            a.delegate = self;
            
            [mediaControlsView addSubview:a];
            [[self progressControl].superview bringSubviewToFront:[self progressControl]];
            [[self volumeSlider].superview bringSubviewToFront:[self volumeSlider]];
            
            //acapella constraints
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:[self volumeSlider]
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            
            [mediaControlsView.superview layoutIfNeeded];
            [mediaControlsView layoutIfNeeded];
            [a layoutIfNeeded];
            
        }
    }
    
    return a;
}

%new
- (void)setAcapella:(SWAcapellaBase *)acapella
{
    objc_setAssociatedObject(self, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSDictionary *)previousNowPlayingInfo
{
    return objc_getAssociatedObject(self, &_previousNowPlayingInfo);
}

%new
- (void)setPreviousNowPlayingInfo:(NSDictionary *)previousNowPlayingInfo
{
    objc_setAssociatedObject(self, &_previousNowPlayingInfo, previousNowPlayingInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Init

- (void)viewDidLoad
{
    %orig();
    
    if (self.acapella){}
    
}

- (void)viewDidLayoutSubviews
{
    if (self.acapella){}
    
    %orig();
    
    if (self.acapella){
        
        UIView *mediaControlsView = [self playbackControlsView];
        
        if (mediaControlsView && [self progressControl]){
            
            //this view keeps on changing, so we have to keep adding the constraint
            [self.acapella.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.acapella
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:[self progressControl]
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0
                                                                                 constant:0.0]];
            [self.acapella.superview layoutIfNeeded];
            [self.acapella layoutIfNeeded];
        }
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    if (self.acapella){
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaRemoteNowPlayingInfoDidChangeNotification)
                                                 name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);
    
    if (self.acapella){
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)arg1
{
    %orig(arg1);
    
    //make sure we clean this up, so we can display it again later
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig(arg1);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                                  object:nil];
    
    MRMediaRemoteUnregisterForNowPlayingNotifications();
}

#pragma mark - Other

//
///*
// - (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2
// {
// %orig(arg1, arg2);
// 
// [self viewDidLayoutSubviews];
// }
// 
// - (void)didRotateFromInterfaceOrientation:(int)arg1
// {
// %orig(arg1);
// 
// [self viewDidLayoutSubviews];
// }
// */
//
%new
- (void)appDidBecomeActive:(NSNotification *)notification
{
    //sometimes third party app is still playing when we open the Music App, so using Acapella will control the third party
    //app instead of the Music App. This ensures the Music app gets set as the now playing application
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        if (resultDict){
            
            BOOL isMusicApp = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoIsMusicApp] boolValue];
            
            if (!isMusicApp){ //reset to music app, so thats what we control
                if ([self player]){
                    [[self player] togglePlayback];
                    [[self player] togglePlayback];
                }
            }
        }
    });
}

#pragma mark - MediaRemote

%new
- (void)mediaRemoteNowPlayingInfoDidChangeNotification
{
    if (!self.view.window){
        return;
    }
    
    if (![NSThread isMainThread]){
        [self performSelectorOnMainThread:@selector(mediaRemoteNowPlayingInfoDidChangeNotification) withObject:nil waitUntilDone:NO];
        return;
    }
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        if (resultDict){
            
            NSNumber *uid = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier];
            NSNumber *previousUID;
            
            if (self.previousNowPlayingInfo){
                previousUID = [self.previousNowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier];
            }
            
            if (uid){
                if (!previousUID || (previousUID && ![uid isEqualToNumber:previousUID])){
                    
                    [self.acapella.scrollview finishWrapAroundAnimation];
                
                } else {
                    
                    NSNumber *elapsedTime = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime];
                    
                    if (elapsedTime && [elapsedTime doubleValue] <= 0.0){ //restarted the song
                        
                        [self.acapella.scrollview finishWrapAroundAnimation];
                    }
                }
            } else {
                
                [self.acapella.scrollview finishWrapAroundAnimation];
            
            }
        }
        
        self.previousNowPlayingInfo = resultDict;
        
    });
}

#pragma mark - SWAcapellaDelegate

%new
- (void)scrollViewDidScroll:(SWAcapellaScrollView *)scrollView
{
    if ([self titlesView]){
        
        //only update alpha if we are not at default position
        //otherwide showing the ratings view glitches
        if (!CGPointEqualToPoint(scrollView.contentOffset, scrollView.defaultContentOffset)){
            
            CGFloat alpha = 1.0 - (fabs(scrollView.contentOffset.y - scrollView.defaultContentOffset.y) / CGRectGetMidY(scrollView.frame));
            [self titlesView].alpha = alpha;
        }
        
        
        CGPoint center = CGPointMake((scrollView.contentSize.width / 2) - scrollView.contentOffset.x,
                                     (scrollView.contentSize.height / 2) - scrollView.contentOffset.y);
        
        center = [self.view convertPoint:center fromView:self.acapella];
        
        [self titlesView].center = center;
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
    if (tap.state == UIGestureRecognizerStateEnded){
        
        swAcapellaAction action;
        
        CGFloat percentBoundaries = SW_ACAPELLA_LEFTRIGHT_VIEW_BOUNDARY_PERCENTAGE;
        
        if (percentage.x <= percentBoundaries){ //left
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"leftTapAction" defaultValue:@10]
                                                 withDelegate:self];
        } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
            
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"centreTapAction" defaultValue:@1]
                                                 withDelegate:self];
            
        } else if (percentage.x > (1.0 - percentBoundaries)){ //right
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"rightTapAction" defaultValue:@11]
                                                 withDelegate:self];
        }
        
        if (action){
            action();
        }
        
    }
}

%new
- (void)swAcapella:(SWAcapellaScrollView *)swAcapella onSwipe:(ScrollDirection)direction
{
    swAcapellaAction action;
    
    [swAcapella stopWrapAroundFallback];
    
    if (direction == ScrollDirectionLeft || direction == ScrollDirectionRight){
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:(direction == ScrollDirectionLeft) ?
                                                           @"swipeLeftAction" : @"swipeRightAction"
                                                                                defaultValue:(direction == ScrollDirectionLeft) ?
                                                           @3 : @2]
                                             withDelegate:self];
        
    } else if (direction == ScrollDirectionUp) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeUpAction" defaultValue:@7]
                                             withDelegate:self];
        
    } else if (direction == ScrollDirectionDown) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeDownAction" defaultValue:@6]
                                             withDelegate:self];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        if (action){
            action();
        } else {
            [swAcapella finishWrapAroundAnimation];
        }
        
    });
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
    CGFloat percentBoundaries = SW_ACAPELLA_LEFTRIGHT_VIEW_BOUNDARY_PERCENTAGE;
    
    swAcapellaAction action;
    
    if (percentage.x <= percentBoundaries){ //left
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"leftPressAction" defaultValue:@4]
                                                 withDelegate:self];
            
        }
        
    } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"centrePressAction" defaultValue:@9]
                                                 withDelegate:self];
            
        }
        
    } else if (percentage.x > (1.0 - percentBoundaries)){ //right
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"rightPressAction" defaultValue:@5]
                                                 withDelegate:self];
            
        }
        
    }
    
    if (action){
        action();
    }
}

#pragma mark - Actions

%new
- (void)action_PlayPause
{
    [SWAcapellaActionsHelper action_PlayPause:^(BOOL successful, id object){
        if (successful && [self titlesView]){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 [self titlesView].transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      [self titlesView].transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      [self titlesView].transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
        }
    }];
}

%new
- (void)action_PreviousSong
{
    [SWAcapellaActionsHelper action_PreviousSong:^(BOOL successful, id object){
        [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
            if (successful){
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self.acapella.scrollview finishWrapAroundAnimation]; //make sure we wrap around on iTunes Radio
                });
                
            } else {
                
                MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul),
                                               ^(CFDictionaryRef result){
                    
                    NSDictionary *resultDict = (__bridge NSDictionary *)result;
                    
                    if (resultDict){
                        
                        double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
                        
                        if (mediaCurrentElapsedDuration >= 2.0 || mediaCurrentElapsedDuration <= 0.0){
                            
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [self.acapella.scrollview finishWrapAroundAnimation];
                            });
                        }
                    }
                });
            }
        }];
    }];
}

%new
- (void)action_NextSong
{
    [SWAcapellaActionsHelper action_NextSong:^(BOOL successful, id object){
    }];
}

%new
- (void)action_SkipBackward
{
    [SWAcapellaActionsHelper action_SkipBackward:nil];
}

%new
- (void)action_SkipForward
{
    [SWAcapellaActionsHelper action_SkipForward:nil];
}

%new
- (void)action_OpenActivity
{
    [SWAcapellaActionsHelper action_OpenActivity:^(BOOL successful, id object){
        
        if (successful && object){
            
            NSDictionary *shareData = (NSDictionary *)object;
            
            if (NSClassFromString(@"UIAlertController")){
                
                UIAlertController *c = [UIAlertController alertControllerWithTitle:@"Share"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction *action) {
                                                                   [self.acapella.scrollview finishWrapAroundAnimation];
                                                               }];
                
                [c addAction:cancel];
                
                
                UIAlertActionStyle hasTwitter = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive;
                
                UIAlertAction *tweet = [UIAlertAction actionWithTitle:@"Twitter"
                                                                style:hasTwitter
                                                              handler:^(UIAlertAction *action) {
                                                                  
                                                                  SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                                                  
                                                                  if ([shareData valueForKey:@"shareString"]){
                                                                      [compose setInitialText:[shareData valueForKey:@"shareString"]];
                                                                  }
                                                                  if ([shareData valueForKey:@"shareImage"]){
                                                                      [compose addImage:[shareData valueForKey:@"shareImage"]];
                                                                  }
                                                                  
                                                                  compose.completionHandler = ^(SLComposeViewControllerResult result) {
                                                                      [self.acapella.scrollview finishWrapAroundAnimation];
                                                                  };
                                                                  
                                                                  [self presentViewController:compose animated:YES completion:nil];
                                                              }];
                
                [c addAction:tweet];
                
                
                
                UIAlertActionStyle hasFacebook = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive;
                
                UIAlertAction *facebook = [UIAlertAction actionWithTitle:@"Facebook"
                                                                   style:hasFacebook
                                                                 handler:^(UIAlertAction *action) {
                                                                     SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                                                                     
                                                                     if ([shareData valueForKey:@"shareString"]){
                                                                         [compose setInitialText:[shareData valueForKey:@"shareString"]];
                                                                     }
                                                                     if ([shareData valueForKey:@"shareImage"]){
                                                                         [compose addImage:[shareData valueForKey:@"shareImage"]];
                                                                     }
                                                                     
                                                                     compose.completionHandler = ^(SLComposeViewControllerResult result) {
                                                                         [self.acapella.scrollview finishWrapAroundAnimation];
                                                                     };
                                                                     
                                                                     [self presentViewController:compose animated:YES completion:nil];
                                                                 }];
                
                [c addAction:facebook];
                
                
                
                [self presentViewController:c animated:YES completion:nil];
                
            } else { //iOS < 8
                
                [self.acapella.scrollview finishWrapAroundAnimation];
                
                UIAlertView *c = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"This feature is only available on iOS 8.0 or greater."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
                [c show];
            }
            
        } else {
            
            [self.acapella.scrollview finishWrapAroundAnimation];
            
        }
    }];
}

%new
- (void)action_ShowPlaylistOptions
{
    [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
        
        NSDictionary *resultDict = object;
        
        if (resultDict){
            
            //int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
            //int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
            
            if (NSClassFromString(@"UIAlertController")){
                
                UIAlertController *c = [UIAlertController alertControllerWithTitle:@"Playlist Options"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction *action) {
                                                                   [self.acapella.scrollview finishWrapAroundAnimation];
                                                               }];
                
                [c addAction:cancel];
                
                
                
                for (NSUInteger x = 0; x < 3; x++){
                    
                    UIAlertAction *repeat = [UIAlertAction actionWithTitle:NSStringForRepeatMode(x)
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       
                                                                       MRMediaRemoteSetRepeatMode(x);
                                                                       [self.acapella.scrollview finishWrapAroundAnimation];
                                                                       
                                                                   }];
                    
                    [c addAction:repeat];
                    
                }
                
                
                for (NSUInteger x = 0; x < 3; x++){
                    
                    if (x != 1){ //1 isnt a valid shuffle mode
                        
                        UIAlertAction *shuffle = [UIAlertAction actionWithTitle:NSStringForShuffleMode(x)
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction *action) {
                                                                            
                                                                            MRMediaRemoteSetShuffleMode(x);
                                                                            [self.acapella.scrollview finishWrapAroundAnimation];
                                                                            
                                                                        }];
                        
                        [c addAction:shuffle];
                        
                    }
                }
                
                
                
                [self presentViewController:c animated:YES completion:nil];
                
            } else { //iOS < 8
                
                [self.acapella.scrollview finishWrapAroundAnimation];
                
                UIAlertView *c = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"This feature is only available on iOS 8.0 or greater."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
                [c show];
            }
            
        } else {
            [self.acapella.scrollview finishWrapAroundAnimation];
        }
    }];
}

%new
- (void)action_OpenApp
{
    //already in app
}

%new
- (void)action_ShowRatingsOpenApp
{
    [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
        if (successful){
            if ([self likeOrBanButton]){
                [[self likeOrBanButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        } else {
            [self _setShowingRatings:YES animated:YES];
        }
    }];
}

%new
- (void)action_DecreaseVolume
{
    [SWAcapellaActionsHelper action_DecreaseVolume:nil];
}

%new
- (void)action_IncreaseVolume
{
    [SWAcapellaActionsHelper action_IncreaseVolume:nil];
}

#pragma mark - Rating

static BOOL _didTouchRatingControl = NO;
static NSTimer *_hideRatingTimer;

- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2
{
    %orig(arg1, arg2);
    
    if (arg1){
        [self startRatingShouldHideTimer];
        self.acapella.userInteractionEnabled = NO;
    } else {
        if (_hideRatingTimer){
            [_hideRatingTimer invalidate];
            _hideRatingTimer = nil;
        }
        self.acapella.userInteractionEnabled = YES;
    }
}

%new
- (void)startRatingShouldHideTimer
{
    BOOL isShowingRating = MSHookIvar<BOOL>(self, "_isShowingRatings");
    
    if (_hideRatingTimer){
        [_hideRatingTimer invalidate];
        _hideRatingTimer = nil;
    }
    
    if (!isShowingRating){
        return;
    }
    
    _hideRatingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                        target:self
                                                      selector:@selector(hideRatingControlWithTimer)
                                                      userInfo:nil
                                                       repeats:NO];
}

%new
- (void)hideRatingControlWithTimer
{
    BOOL isShowingRating = MSHookIvar<BOOL>(self, "_isShowingRatings");
    
    if (!isShowingRating){
        _didTouchRatingControl = NO;
        return;
    }
    
    if (_didTouchRatingControl){
        _didTouchRatingControl = NO;
        [self startRatingShouldHideTimer];
        return;
    }
    
    [self _setShowingRatings:NO animated:YES];
    _didTouchRatingControl = NO;
}

%end





%hook MPURatingControl //keep track of touches and delay our hide timer

- (void)_handlePanGesture:(id)arg1
{
    %orig(arg1);
    
    _didTouchRatingControl = YES;
}

- (void)_handleTapGesture:(id)arg1
{
    %orig(arg1);
    
    _didTouchRatingControl = YES;
}

%end





#pragma mark - MPPlaybackControlsView

static void mpPlaybackControlsPostLayout(UIView *mpu)
{
    UIView *transport = MSHookIvar<UIView *>(mpu, "_transportControls");
    [transport removeFromSuperview];
    
    //this will update the text center
    for (UIView *v in mpu.subviews){
        if ([v isKindOfClass:%c(SWAcapellaBase)]){
            SWAcapellaBase *acapella = (SWAcapellaBase *)v;
            [acapella scrollViewDidScroll:acapella.scrollview];
        }
    }
}

%hook MusicNowPlayingPlaybackControlsView

- (void)layoutIfNeeded
{
    %orig();
    
    mpPlaybackControlsPostLayout(self);
}

- (void)layoutSubviews
{
    //wierd crash with iOS 7, have to call twice :O
    %orig();
    mpPlaybackControlsPostLayout(self);
    %orig();
    mpPlaybackControlsPostLayout(self);
}

%end





#pragma mark - logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




