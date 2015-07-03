
#import <Social/Social.h>

#import "libSluthware.h"
#import "AcapellaKit.h"
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"

#import <Springboard/Springboard.h>
#import <MediaRemote/MediaRemote.h>

#import "MPUSystemMediaControlsViewController.h"
#import "MPUSystemMediaControlsView.h"
#import "MPUMediaControlsVolumeView.h"
#import "MPUItemOfferButton.h"

#import "substrate.h"





#pragma mark - MPUSystemMediaControlsViewController

static SWAcapellaBase *_acapella;

static NSDictionary *_previousNowPlayingInfo;





@interface MPUSystemMediaControlsViewController(SW)
{
}

@property (strong, nonatomic) SWAcapellaBase *acapella;

@property (strong, nonatomic) NSDictionary *previousNowPlayingInfo;

- (UIView *)mediaControlsView;
- (UIView *)progressControl;
- (UIView *)trackInformationView;
- (UIView *)transportControls;
- (UIView *)volumeView;
- (UIView *)buyTrackButton;
- (UIView *)buyAlbumButton;
- (UIView *)skipLimitView;

@end





%hook MPUSystemMediaControlsViewController

#pragma mark - Helper

%new
- (UIView *)mediaControlsView
{
    return MSHookIvar<UIView *>(self, "_mediaControlsView");
}

%new
- (UIView *)progressControl
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_timeInformationView");
}

%new
- (UIView *)trackInformationView
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_trackInformationView");
}

%new
- (UIView *)transportControls
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_transportControlsView");
}

%new
- (UIView *)volumeView
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_volumeView");
}

%new
- (UIView *)buyTrackButton
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"8")){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_buyTrackButton");
}

%new
- (UIView *)buyAlbumButton
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"8")){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_buyAlbumButton");
}

%new
- (UIView *)skipLimitView
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"8")){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_skipLimitView");
}

%new
- (SWAcapellaBase *)acapella
{
    if (!self.view.window.rootViewController){
        
        if ([self.view.superview isKindOfClass:%c(OTMView)]){ //OnTapMusic
            
            if (![[SWAcapellaPrefsBridge valueForKey:@"otm_enabled" defaultValue:@YES] boolValue]){
                return nil;
            }
            
        } else {
            return nil;
        }
        
    } else {
        
        NSString *key;
        
        if ([self.view.window.rootViewController class] == %c(SBControlCenterController)){
            key = @"cc_enabled";
        } else { //SBMainScreenAlertWindowViewController -> Lock Screen
            key = @"ls_enabled";
        }
        
        if (![[SWAcapellaPrefsBridge valueForKey:key defaultValue:@YES] boolValue]){
            return nil;
        }
    }
    
    SWAcapellaBase *a = objc_getAssociatedObject(self, &_acapella);
    
    if (!a){
        
        UIView *mediaControlsView = [self mediaControlsView];
        
        if (mediaControlsView) {
            
            //make sure views are all setup for constraints
            if (!([self progressControl] &&
                  [self volumeView])){
                return nil;
            }
            
            [self setAcapella:[[%c(SWAcapellaBase) alloc] init]];
            a = objc_getAssociatedObject(self, &_acapella);
            a.delegate = self;
            
            [mediaControlsView addSubview:a];
            
            //acapella constraints
            self.acapella.widthConstraint = [NSLayoutConstraint constraintWithItem:a
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:mediaControlsView
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0
                                                                          constant:0.0];
            [mediaControlsView addConstraint:self.acapella.widthConstraint];
            
            self.acapella.heightConstraint = [NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1.0
                                                                           constant:0.0];
            [mediaControlsView addConstraint:self.acapella.heightConstraint];
            
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            
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
    
    UIView *mediaControlsView = [self mediaControlsView];
    
    if (self.acapella){
        
        [mediaControlsView.superview layoutIfNeeded];
        [self.acapella layoutIfNeeded];
        
    }
    
    %orig(); //calling this again will ensure the titles view is centered off the bat
    
    if (self.acapella){
        
        if ([self progressControl].superview == mediaControlsView){
            [[self progressControl] removeFromSuperview];
        }
        
        if ([self volumeView].superview == mediaControlsView){
            [[self volumeView] removeFromSuperview];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    if (self.acapella){
        [self.acapella.scrollview resetContentOffset:NO];
    }
    
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
        [self.acapella.scrollview resetContentOffset:NO];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                                  object:nil];
    
    MRMediaRemoteUnregisterForNowPlayingNotifications();
}

#pragma mark - MediaRemote

%new
- (void)mediaRemoteNowPlayingInfoDidChangeNotification
{
    if (!self.view.window || !self.acapella){
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
                if (!previousUID || (previousUID && ![uid isEqualToNumber:previousUID])){ //new song
                    
                    [self.acapella.scrollview finishWrapAroundAnimation];
                    
                } else {
                    
                    NSNumber *elapsedTime = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime];
                    
                    if (elapsedTime && [elapsedTime doubleValue] <= 0.0){ //restarted the song
                        
                        [self.acapella.scrollview finishWrapAroundAnimation];
                        
                    }
                    
                }
            } else { //3rd party apps, which have no UID's
                
                NSString *itemTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                NSString *previousItemTitle;
                
                if (self.previousNowPlayingInfo){
                    previousItemTitle = [self.previousNowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                }
                
                if (!previousItemTitle || (previousItemTitle && ![itemTitle isEqualToString:previousItemTitle])){ //new song
                    
                    [self.acapella.scrollview finishWrapAroundAnimation];
                    
                } else {
                    
                    NSNumber *elapsedTime = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime];
                    
                    if (elapsedTime && [elapsedTime doubleValue] <= 0.0){ //restarted the song
                        
                        [self.acapella.scrollview finishWrapAroundAnimation];
                        
                    }
                    
                }
                
            }
        } else {
            
            [self.acapella.scrollview finishWrapAroundAnimation];
            
        }
        
        self.previousNowPlayingInfo = resultDict;
        
    });
}

#pragma mark - SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)swAcapella onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
    if (tap.state == UIGestureRecognizerStateEnded){
        
        swAcapellaAction action;
        
        CGFloat percentBoundaries = 0.2;
        
        if (percentage.x <= percentBoundaries){ //left
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"leftTapAction" defaultValue:@7]
                                                 withDelegate:self];
        } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
            
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"centreTapAction" defaultValue:@1]
                                                 withDelegate:self];
            
        } else if (percentage.x > (1.0 - percentBoundaries)){ //right
            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                               valueForKey:@"rightTapAction" defaultValue:@8]
                                                 withDelegate:self];
        }
        
        if (action){
            action();
        }
        
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)swAcapella onSwipe:(UISwipeGestureRecognizerDirection)direction
{
    swAcapellaAction action;
    
    [self.acapella.scrollview stopWrapAroundFallback];
    
    if (direction == UISwipeGestureRecognizerDirectionLeft){
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:@"swipeLeftAction" defaultValue:@3]
                                             withDelegate:self];
        
    } else if (direction == UISwipeGestureRecognizerDirectionRight){
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:@"swipeRightAction" defaultValue:@2]
                                             withDelegate:self];
        
    } else if (direction == UISwipeGestureRecognizerDirectionUp) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeUpAction" defaultValue:@0]
                                             withDelegate:self];
        
    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeDownAction" defaultValue:@0]
                                             withDelegate:self];
        
    }
    
    if (action){
        action();
    } else {
        [self.acapella.scrollview finishWrapAroundAnimation];
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)swAcapella onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
    CGFloat percentBoundaries = 0.2;
    
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
                                                               valueForKey:@"centrePressAction" defaultValue:@6]
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
        if (successful && self.acapella){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 self.acapella.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      self.acapella.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      self.acapella.transform = CGAffineTransformMakeScale(1.0, 1.0);
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
            if (successful || !object){
                [self.acapella.scrollview finishWrapAroundAnimation]; //make sure we wrap around on iTunes Radio
            } else {
                //fallback for some third party apps not wrapping around when you cant skip to the previous song
                [self.acapella.scrollview startWrapAroundFallback];
            }
        }];
    }];
}

%new
- (void)action_NextSong
{
    MRMediaRemoteSendCommand(kMRNextTrack, nil);
//    [SWAcapellaActionsHelper action_NextSong:^(BOOL successful, id object){
//        
//        if (!object){
//            [self.acapella.scrollview finishWrapAroundAnimation];
//        } else {
//            [self.acapella.scrollview startWrapAroundFallback];
//        }
//    }];
}

%new
- (void)action_SkipBackward
{
    [SWAcapellaActionsHelper action_SkipBackward];
}

%new
- (void)action_SkipForward
{
    [SWAcapellaActionsHelper action_SkipForward];
}

%new
- (void)action_ShowRatings
{
}

%new
- (void)action_DecreaseVolume
{
    [SWAcapellaActionsHelper action_DecreaseVolume];
}

%new
- (void)action_IncreaseVolume
{
    [SWAcapellaActionsHelper action_IncreaseVolume];
}

%end





#pragma mark - MPUSystemMediaControlsView

static void mpuPostLayoutSubviews(UIView *mpu)
{
    SWAcapellaBase *acapella;
    
    for (UIView *v in mpu.subviews){
        if ([v isKindOfClass:%c(SWAcapellaBase)]){
            acapella = (SWAcapellaBase *)v;
        }
    }
    
    if (acapella){ //if acapella is not nil, then we know it is enabled
        
        //UIView *time = MSHookIvar<UIView *>(mpu, "_timeInformationView");
        UIView *titles = MSHookIvar<UIView *>(mpu, "_trackInformationView");
        UIView *transport = MSHookIvar<UIView *>(mpu, "_transportControlsView");
        //UIView *volume = MSHookIvar<UIView *>(mpu, "_volumeView");
        
        if (titles){
            [acapella.scrollview addSubview:titles];
            titles.frame = titles.frame; //center
        }
        
        if (transport){
            transport.center = CGPointMake(6900, transport.center.y);
        }
        
    }
}

%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    mpuPostLayoutSubviews(self);
}

%end





#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
//    if ([[SWAcapellaPrefsBridge valueForKey:@"cc_enabled" defaultValue:@YES] boolValue]){
//        return CGSizeMake(original.width, original.height * 0.75);
//    }
    
    return original;
}

%end





#pragma mark - logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




