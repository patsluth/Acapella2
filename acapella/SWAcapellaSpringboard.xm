

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import <libsw/SWAppLauncher.h>
#import "SWAcapellaSharingFormatter.h"
#import "SWAcapellaPrefsBridge.h"

#import <Springboard/Springboard.h>
#import <MediaRemote/MediaRemote.h>

#import "MPUSystemMediaControlsViewController+SW.h"
#import "_MPUSystemMediaControlsView.h" //iOS 7
#import "MPUSystemMediaControlsView.h" //iOS 8
#import "MPUNowPlayingController.h"
#import "MPUChronologicalProgressView.h"
#import "MPUMediaControlsTitlesView.h"
#import "MPUMediaControlsVolumeView.h"
#import "MPUItemOfferButton.h"
#import "SBCCMediaControlsSectionController.h"
#import "AVSystemController+SW.h"

#import "substrate.h"
#import <objc/runtime.h>
#import "dlfcn.h"





#pragma mark MPUSystemMediaControlsViewController

#define SW_ACAPELLA_REPEATSHUFFLE_Y_PADDING 5
#define SW_ACAPELLA_REPEATSHUFFLE_X_PADDING 10

#define SW_ACAPELLA_LEFTRIGHT_VIEW_BOUNDARY_PERCENTAGE 0.25

static SWAcapellaBase *_acapella;
static UIActivityViewController *_acapellaSharingActivityView;
static UIButton *_acapellaRepeatButton;
static UIButton *_acapellaShuffleButton;
static NSTimer *_acapellaHideRepeatAndShuffleButtonsTimer;




@interface MPUSystemMediaControlsViewController()
{
}

@property (strong, nonatomic) UIActivityViewController *acapellaSharingActivityView;
@property (strong, nonatomic) UIButton *acapellaRepeatButton;
@property (strong, nonatomic) UIButton *acapellaShuffleButton;
@property (strong, nonatomic) NSTimer *acapellaHideRepeatAndShuffleButtonsTimer;

- (void)cleanupRepeatAndShuffleButtons;
- (void)updateRepeatButtonToMediaRepeatMode:(int)repeatMode;
- (void)updateShuffleButtonToMediaShuffleMode:(int)shuffleMode;
- (void)startHideRepeatAndShuffleButtonTimer;
- (void)stopHideRepeatAndShuffleButtonTimer;

//actions
- (void)attemptToOpenNowPlayingApp;

@end






%hook MPUSystemMediaControlsViewController

#pragma mark Helper

%new
- (UIView *)mediaControlsView
{
    return MSHookIvar<UIView *>(self, "_mediaControlsView");
}

%new
- (UIView *)timeInformationView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_timeInformationView");
}

%new
- (UIView *)trackInformationView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_trackInformationView");
}

%new
- (UIView *)transportControlsView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_transportControlsView");
}

%new
- (UIView *)volumeView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_volumeView");
}

%new
- (UIView *)buyTrackButton
{
    if ([SWDeviceInfo iOSVersion_First] != 8){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_buyTrackButton");
}

%new
- (UIView *)buyAlbumButton
{
    if ([SWDeviceInfo iOSVersion_First] != 8){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_buyAlbumButton");
}

%new
- (UIView *)skipLimitView
{
    if ([SWDeviceInfo iOSVersion_First] != 8){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_skipLimitView");
}

%new
- (SWAcapellaBase *)acapella
{
    return objc_getAssociatedObject(self, &_acapella);
}

%new
- (void)setAcapella:(SWAcapellaBase *)acapella
{
    objc_setAssociatedObject(self, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIActivityViewController *)acapellaSharingActivityView
{
    return objc_getAssociatedObject(self, &_acapellaSharingActivityView);
}

%new
- (void)setAcapellaSharingActivityView:(UIActivityViewController *)acapellaSharingActivityView
{
    objc_setAssociatedObject(self, &_acapellaSharingActivityView, acapellaSharingActivityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIButton *)acapellaRepeatButton
{
    return objc_getAssociatedObject(self, &_acapellaRepeatButton);
}

%new
- (void)setAcapellaRepeatButton:(UIButton *)acapellaRepeatButton
{
    objc_setAssociatedObject(self, &_acapellaRepeatButton, acapellaRepeatButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIButton *)acapellaShuffleButton
{
    return objc_getAssociatedObject(self, &_acapellaShuffleButton);
}

%new
- (void)setAcapellaShuffleButton:(UIButton *)acapellaShuffleButton
{
    objc_setAssociatedObject(self, &_acapellaShuffleButton, acapellaShuffleButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSTimer *)acapellaHideRepeatAndShuffleButtonsTimer
{
    return objc_getAssociatedObject(self, &_acapellaHideRepeatAndShuffleButtonsTimer);
}

%new
- (void)setAcapellaHideRepeatAndShuffleButtonsTimer:(UIButton *)acapellaHideRepeatAndShuffleButtonsTimer
{
    objc_setAssociatedObject(self, &_acapellaHideRepeatAndShuffleButtonsTimer, acapellaHideRepeatAndShuffleButtonsTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Init

- (void)viewDidLoad
{
    %orig();
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    UIView *mediaControlsView = [self mediaControlsView];
    
    if (mediaControlsView){
        
        if ([self timeInformationView].superview == mediaControlsView){
            [[self timeInformationView] removeFromSuperview];
        }
        if ([self trackInformationView].superview == mediaControlsView){
            [[self trackInformationView] removeFromSuperview];
        }
        if ([self transportControlsView].superview == mediaControlsView){
            [[self transportControlsView] removeFromSuperview];
        }
        if ([self volumeView].superview == mediaControlsView){
            [[self volumeView] removeFromSuperview];
        }
        
        
        if (!self.acapella){
            self.acapella = [[%c(SWAcapellaBase) alloc] init];
            self.acapella.delegateAcapella = self;
        }
        
        self.acapella.frame = mediaControlsView.frame;
        [mediaControlsView.superview addSubview:self.acapella];
        
        [self trackInformationView].userInteractionEnabled = NO;
        
        if ([self timeInformationView].frame.size.height * 3.0 != self.acapella.acapellaTopAccessoryHeight){
            self.acapella.acapellaTopAccessoryHeight = [self timeInformationView].frame.size.height * 3.0;
        }
        
        if ([self volumeView].frame.size.height * 2.0 != self.acapella.acapellaBottomAccessoryHeight){
            self.acapella.acapellaBottomAccessoryHeight = [self volumeView].frame.size.height * 2.0;
        }
        
        if ([self buyTrackButton]){
            [mediaControlsView.superview addSubview:[self buyTrackButton]];
        }
        if ([self buyAlbumButton]){
            [mediaControlsView.superview addSubview:[self buyAlbumButton]];
        }
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
    
    if (self.acapella){
        if (self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:NO];
        }
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
    
    if (self.acapella){
        if (self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:NO];
        }
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
        if (self.acapellaSharingActivityView){
            self.acapellaSharingActivityView.completionHandler = nil;
            self.acapellaSharingActivityView = nil;
        }
    }];
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig(arg1);
    
    [self stopHideRepeatAndShuffleButtonTimer];
    [self cleanupRepeatAndShuffleButtons];
}

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
    if (tap.state == UIGestureRecognizerStateEnded){
        
        swAcapellaAction action;
        
        CGFloat percentBoundaries = SW_ACAPELLA_LEFTRIGHT_VIEW_BOUNDARY_PERCENTAGE;
        
        if (percentage.x <= percentBoundaries){ //left
            action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"leftTapAction" defaultValue:@10]];
        } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
            
            action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"centreTapAction" defaultValue:@1]];
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 view.tableview.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      view.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      view.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
            
        } else if (percentage.x > (1.0 - percentBoundaries)){ //right
            action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"rightTapAction" defaultValue:@11]];
        }
        
        if (action){
            action();
        }
        
    }
}

%new
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    swAcapellaAction action;
    
    [view stopWrapAroundFallback];
    
    if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
        
        [view stopWrapAroundFallback];
        
        action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:(direction == SW_SCROLL_DIR_LEFT) ?
                                        @"swipeLeftAction" : @"swipeRightAction"
                                                             defaultValue:(direction == SW_SCROLL_DIR_LEFT) ?
                                        @2 : @3]];
        
    } else if (direction == SW_SCROLL_DIR_UP) {
        
        action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"swipeUpAction" defaultValue:@6]];
        
    } else if (direction == SW_SCROLL_DIR_DOWN) {
        
        action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"swipeDownAction" defaultValue:@7]];
        
    }
    
    if (action){
        action();
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
    CGFloat percentBoundaries = SW_ACAPELLA_LEFTRIGHT_VIEW_BOUNDARY_PERCENTAGE;
    
    swAcapellaAction action;
    
    if (percentage.x <= percentBoundaries){ //left
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"leftPressAction" defaultValue:@4]];
            
        }
        
    } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"centrePressAction" defaultValue:@9]];
            
        }
        
    } else if (percentage.x > (1.0 - percentBoundaries)){ //right
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            action = [self methodForAction:[SWAcapellaPrefsBridge valueForKey:@"rightPressAction" defaultValue:@5]];
            
        }
        
    }
    
    if (action){
        action();
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIView *mediaControlsView = [self mediaControlsView];
    
    if (mediaControlsView){
        
        if (indexPath.section == 0){
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                case 1:
                    
                    if ([self volumeView]){
                        [[self volumeView] removeFromSuperview];
                    }
                    
                    if ([self timeInformationView]){
                        [cell addSubview:[self timeInformationView]];
                    }
                    
                    break;
                    
                case 2:
                    
                    if ([self trackInformationView] && view.scrollview){
                        [view.scrollview addSubview:[self trackInformationView]];
                    }
                    
                    break;
                    
                case 3:
                    
                    if ([self timeInformationView]){
                        [[self timeInformationView] removeFromSuperview];
                    }
                    
                    if ([self volumeView]){
                        [cell addSubview:[self volumeView]];
                    }
                    
                    break;
                    
                case 4:
                    
                    break;
                    
                default:
                    break;
            }
        }
        
        [mediaControlsView layoutSubviews];
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark Actions

%new
- (swAcapellaAction)methodForAction:(NSNumber *)action
{
    if ([action isEqualToNumber:@1]){
        return ^(){
            [self action_PlayPause];
        };
    } else if ([action isEqualToNumber:@2]){
        return ^(){
            [self action_PreviousSong];
        };
    } else if ([action isEqualToNumber:@3]){
        return ^(){
            [self action_NextSong];
        };
    } else if ([action isEqualToNumber:@4]){
        return ^(){
            [self action_SkipBackward];
        };
    } else if ([action isEqualToNumber:@5]){
        return ^(){
            [self action_SkipForward];
        };
    } else if ([action isEqualToNumber:@6]){
        return ^(){
            [self action_OpenActivity];
        };
    } else if ([action isEqualToNumber:@7]){
        return ^(){
            [self action_ShowPlaylistOptions];
        };
    } else if ([action isEqualToNumber:@8]){
        return ^(){
            [self action_OpenAppShowRatings];
        };
    } else if ([action isEqualToNumber:@9]){
        return ^(){
            [self action_ShowRatingsOpenApp];
        };
    } else if ([action isEqualToNumber:@10]){
        return ^(){
            [self action_DecreaseVolume];
        };
    } else if ([action isEqualToNumber:@11]){
        return ^(){
            [self action_IncreaseVolume];
        };
    }
    
    return nil;
}

%new
- (void)action_PlayPause
{
    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
}

%new
- (void)action_PreviousSong
{
    [self skipSongInDirection:-1];
}

%new
- (void)action_NextSong
{
    [self skipSongInDirection:1];
}

%new
- (void)skipSongInDirection:(int)direction
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (!result){ //nothing playing
                if (self.acapella && self.acapella.scrollview){
                    [self.acapella.scrollview finishWrapAroundAnimation];
                }
            } else {
                MRMediaRemoteSendCommand((direction <= -1) ? kMRPreviousTrack : kMRNextTrack, nil);
            }
        }];
    });
}

%new
- (void)action_SkipBackward
{
    [self changeSongTimeBySeconds:-20];
}

%new
- (void)action_SkipForward
{
    [self changeSongTimeBySeconds:20];
}

%new
- (void)changeSongTimeBySeconds:(double)seconds
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        if (result){
            NSDictionary *resultDict = (__bridge NSDictionary *)result;
            double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
            MRMediaRemoteSetElapsedTime(mediaCurrentElapsedDuration + seconds);
        }
    });
}

%new
- (void)action_OpenActivity
{
    SBDeviceLockController *deviceLC = (SBDeviceLockController *)[%c(SBDeviceLockController) sharedController];
    
    if (deviceLC && deviceLC.isPasscodeLocked){
        
        __block SWAcapellaTableView *blockTableView = self.acapella.tableview;
        
        [[[SWUIAlertView alloc] initWithTitle:@"Acapella"
                                      message:@"Your device must be unlocked to bring up the activity screen for security reasons. Unlock device and try again."
                           clickedButtonBlock:^(UIAlertView *alert, NSInteger buttonIndex){
                           }
                              didDismissBlock:^(UIAlertView *alert, NSInteger buttonIndex){
                                  if (blockTableView){
                                      [blockTableView finishWrapAroundAnimation];
                                  }
                              }
                            cancelButtonTitle:@":(-+--<" otherButtonTitles:nil] show];
        
    } else {
        
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
            if (result){
                
                NSDictionary *resultDict = (__bridge NSDictionary *)result;
                
                NSString *mediaTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                NSString *mediaArtist = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
                NSData *mediaArtworkData = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
                NSString *sharingHashtag = [%c(SWAcapellaPrefsBridge) valueForKey:@"sharingHashtag" defaultValue:@"acapella"];
                
                NSArray *shareData = [%c(SWAcapellaSharingFormatter) formattedShareArrayWithMediaTitle:mediaTitle
                                                                                           mediaArtist:mediaArtist
                                                                                      mediaArtworkData:mediaArtworkData
                                                                                        sharingHashtag:sharingHashtag];
                
                if (shareData){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        self.acapellaSharingActivityView = [[UIActivityViewController alloc] initWithActivityItems:shareData applicationActivities:nil];
                        [self presentViewController:self.acapellaSharingActivityView animated:YES completion:nil];
                        
                        __block SWAcapellaTableView *blockTableView = self.acapella.tableview;
                        
                        self.acapellaSharingActivityView.completionHandler = ^(NSString *activityType, BOOL completed){
                            if (blockTableView){
                                [blockTableView finishWrapAroundAnimation];
                            }
                        };
                        
                    }];
                } else {
                    [self.acapella.tableview finishWrapAroundAnimation];
                }
                
            } else {
                [self.acapella.tableview finishWrapAroundAnimation];
            }
        });
    }
}

%new
- (void)action_ShowPlaylistOptions
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        if (result){
            
            NSDictionary *resultDict = (__bridge NSDictionary *)result;
            NSString *mediaRadioStationID = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRadioStationIdentifier];
            
            if (!mediaRadioStationID && (!self.acapellaRepeatButton && !self.acapellaShuffleButton)){
                
                self.acapellaRepeatButton = [UIButton buttonWithType:UIButtonTypeSystem];
                [[self.acapellaRepeatButton layer] setMasksToBounds:YES];
                [[self.acapellaRepeatButton layer] setCornerRadius:5.0f];
                [self.acapellaRepeatButton addTarget:self action:@selector(acapellaRepeatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                self.acapellaShuffleButton = [UIButton buttonWithType:UIButtonTypeSystem];
                [self.acapellaShuffleButton addTarget:self action:@selector(acapellaShuffleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [[self.acapellaShuffleButton layer] setMasksToBounds:YES];
                [[self.acapellaShuffleButton layer] setCornerRadius:5.0f];
                
                NSDictionary *resultDict = (__bridge NSDictionary *)result;
                int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
                int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
                
                [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
                [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self.acapellaRepeatButton setOrigin:CGPointMake((self.acapella.scrollview.contentSize.width /
                                                                      [self.acapella.scrollview pagesAvailable].x) +
                                                                     SW_ACAPELLA_REPEATSHUFFLE_X_PADDING,
                                                                     (self.acapella.scrollview.contentSize.height /
                                                                      [self.acapella.scrollview pagesAvailable].y) - 																													self.acapellaRepeatButton.frame.size.height -
                                                                     SW_ACAPELLA_REPEATSHUFFLE_Y_PADDING)];
                    
                    [self.acapella.scrollview addSubview:self.acapellaRepeatButton];
                    
                    
                    [self.acapellaShuffleButton setOrigin:CGPointMake(((self.acapella.scrollview.contentSize.width /
                                                                        [self.acapella.scrollview pagesAvailable].x) +
                                                                       self.acapella.scrollview.frame.size.width) -
                                                                      self.acapellaShuffleButton.frame.size.width - SW_ACAPELLA_REPEATSHUFFLE_X_PADDING,
                                                                      self.acapellaRepeatButton.frame.origin.y)];
                    
                    [self.acapella.scrollview addSubview:self.acapellaShuffleButton];
                    
                    
                    
                    [self.acapella.scrollview stopWrapAroundFallback];
                    [self.acapella.scrollview resetContentOffset:NO];
                    [self.acapella.tableview finishWrapAroundAnimation];
                    [self startHideRepeatAndShuffleButtonTimer];
                }];
                
            } else {
                
                [self cleanupRepeatAndShuffleButtons];
                [self.acapella.tableview finishWrapAroundAnimation];
                
            }
            
        } else {
            
            [self cleanupRepeatAndShuffleButtons];
            [self.acapella.tableview finishWrapAroundAnimation];
            
        }
    });
}

%new
- (void)action_OpenAppShowRatings
{
    [self attemptToOpenNowPlayingApp];
}

%new
- (void)action_ShowRatingsOpenApp
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (result){
                
                NSDictionary *resultDict = (__bridge NSDictionary *)result;
                NSString *mediaRadioStationID = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRadioStationIdentifier];
                
                if (mediaRadioStationID){
                    [self _likeBanButtonTapped:nil];
                } else {
                    [self attemptToOpenNowPlayingApp];
                }
                
            } else {
                
                [self attemptToOpenNowPlayingApp];
                
            }
            
        }];
    });
}

%new
- (void)attemptToOpenNowPlayingApp
{
    MRMediaRemoteGetNowPlayingApplicationPID(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(int PID){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            SBApplication *nowPlayingApp = [[%c(SBApplicationController) sharedInstance] applicationWithPid:PID];
            
            if (!nowPlayingApp){ //fallback
                nowPlayingApp = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.apple.Music"];
            }
            
            [%c(SWAppLauncher) launchAppLockscreenFriendly:nowPlayingApp];
            
        }];
    });
}

%new
- (void)action_DecreaseVolume
{
    [%c(AVSystemController) acapellaChangeVolume:-1];
}

%new
- (void)action_IncreaseVolume
{
    [%c(AVSystemController) acapellaChangeVolume:1];
}

#pragma mark Repeat/Shuffle

%new
- (void)cleanupRepeatAndShuffleButtons
{
	[self stopHideRepeatAndShuffleButtonTimer];

    if (self.acapellaRepeatButton){
        [self.acapellaRepeatButton removeFromSuperview];
        self.acapellaRepeatButton = nil;
    }
    
    if (self.acapellaShuffleButton){
        [self.acapellaShuffleButton removeFromSuperview];
        self.acapellaShuffleButton = nil;
    }
}

%new
- (void)updateRepeatButtonToMediaRepeatMode:(int)repeatMode
{
    //UIColor *primaryTextColor = [UIColor whiteColor];
    UIColor *secondaryTextColor = [UIColor blackColor];
    
    if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
        MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
        //primaryTextColor = [titles _titleLabel].textColor;
        secondaryTextColor = [titles _detailLabel].textColor;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSString *newText;
        
        if (repeatMode == 0){
            newText = @"Repeat Off";
            //self.acapellaRepeatButton.backgroundColor = [UIColor clearColor];
        } else if (repeatMode == 1){
            newText = @"Repeat One";
            //self.acapellaRepeatButton.backgroundColor = primaryTextColor;
        } else if (repeatMode == 2){
            newText = @"Repeat All";
            //self.acapellaRepeatButton.backgroundColor = primaryTextColor;
        }
        
        [self.acapellaRepeatButton setAttributedTitle:[[NSAttributedString alloc] initWithString:newText
                                                                                      attributes:@{NSForegroundColorAttributeName:secondaryTextColor}]
                                             forState:UIControlStateNormal];
        
        [self.acapellaRepeatButton sizeToFit];
        
        [self.acapellaRepeatButton setOrigin:CGPointMake((self.acapella.scrollview.contentSize.width /
                                                                          [self.acapella.scrollview pagesAvailable].x) +
                                                                          SW_ACAPELLA_REPEATSHUFFLE_X_PADDING,
                                                                         (self.acapella.scrollview.contentSize.height /
                                                                          [self.acapella.scrollview pagesAvailable].y) - 																													self.acapellaRepeatButton.frame.size.height -
                                                                          SW_ACAPELLA_REPEATSHUFFLE_Y_PADDING)];
        
    }];
}

%new
- (void)updateShuffleButtonToMediaShuffleMode:(int)shuffleMode
{
    //UIColor *primaryTextColor = [UIColor whiteColor];
    UIColor *secondaryTextColor = [UIColor blackColor];
    
    if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
        MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
        //primaryTextColor = [titles _titleLabel].textColor;
        secondaryTextColor = [titles _detailLabel].textColor;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSString *newText;
        
        if (shuffleMode == 0){ //shuffle is off
            newText = @"Shuffle";
            //self.acapellaShuffleButton.backgroundColor = [UIColor clearColor];
        } else if (shuffleMode == 2){ //shuffle all is on
            newText = @"Shuffle All";
            //self.acapellaShuffleButton.backgroundColor = primaryTextColor;
        }
        
        [self.acapellaShuffleButton setAttributedTitle:[[NSAttributedString alloc] initWithString:newText
                                                                                       attributes:@{NSForegroundColorAttributeName:secondaryTextColor}]
                                              forState:UIControlStateNormal];
        
        [self.acapellaShuffleButton sizeToFit];
        
        [self.acapellaShuffleButton setOrigin:CGPointMake(((self.acapella.scrollview.contentSize.width /
                                                                            [self.acapella.scrollview pagesAvailable].x) +
                                                                           self.acapella.scrollview.frame.size.width) -
                                                                          self.acapellaShuffleButton.frame.size.width - SW_ACAPELLA_REPEATSHUFFLE_X_PADDING,
                                                                          self.acapellaRepeatButton.frame.origin.y)];
        
    }];
}

%new
- (void)acapellaRepeatButtonTapped:(UIButton *)button
{
    [self startHideRepeatAndShuffleButtonTimer]; //reset timer
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        if (result){
            NSDictionary *resultDict = (__bridge NSDictionary *)result;
            int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
            
            mediaRepeatMode = ((mediaRepeatMode + 1) > 2) ? 0 : mediaRepeatMode + 1;
            MRMediaRemoteSetRepeatMode(mediaRepeatMode);
            
            [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
        }
    });
}

%new
- (void)acapellaShuffleButtonTapped:(UIButton *)button
{
    [self startHideRepeatAndShuffleButtonTimer]; //reset timer
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        if (result){
            NSDictionary *resultDict = (__bridge NSDictionary *)result;
            int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
           
			mediaShuffleMode = (mediaShuffleMode == 0) ? 2 : 0; //0 is off, 2 is on
            MRMediaRemoteSetShuffleMode(mediaShuffleMode);
            
            [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
        }
    });
}

%new
- (void)startHideRepeatAndShuffleButtonTimer
{
    [self stopHideRepeatAndShuffleButtonTimer];
    
    self.acapellaHideRepeatAndShuffleButtonsTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                                                      block:^{
                                                                                          if (self.acapellaRepeatButton && self.acapellaShuffleButton){
                                                                                              [UIView animateWithDuration:0.4
                                                                                                                    delay:0.0
                                                                                                                  options:UIViewAnimationOptionCurveEaseInOut
                                                                                                               animations:^{
                                                                                                                   self.acapellaRepeatButton.alpha = 0.0;
                                                                                                                   self.acapellaShuffleButton.alpha = 0.0;
                                                                                                               }
                                                                                                               completion:^(BOOL finished){
                                                                                                                   
                                                                                                                   [self cleanupRepeatAndShuffleButtons];
                                                                                                                   
                                                                                                               }];
                                                                                          } else {
	                                                                                          [self cleanupRepeatAndShuffleButtons];
                                                                                          }
                                                                                      }repeats:NO];
}

%new
- (void)stopHideRepeatAndShuffleButtonTimer
{
    if (self.acapellaHideRepeatAndShuffleButtonsTimer){
        [self.acapellaHideRepeatAndShuffleButtonsTimer invalidate];
        self.acapellaHideRepeatAndShuffleButtonsTimer = nil;
    }
}

%end





#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return CGSizeMake(original.width, original.height * 0.80);
    }
    
    return original;
}

%end





%hook MPUChronologicalProgressView

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")]){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





%hook MPUMediaControlsVolumeView

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")]){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





#pragma mark LockScreen ScrollView

%hook SBLockScreenScrollView

%new
- (UIImageView *)mediaArtworkView
{
    UIImageView *artworkView = nil;
    
    for (UIView *x in self.subviews){
        for (UIView *y in x.subviews){
            if ([y isKindOfClass:NSClassFromString(@"_NowPlayingArtView")]){
                for (UIView *z in y.subviews){
                    if ([z isKindOfClass:[UIImageView class]]){
                        artworkView = (UIImageView *)z;
                    }
                }
            }
        }
    }
    
    return artworkView;
}

%end

%hook SBLockScreenViewController

- (void)viewDidLayoutSubviews
{
    %orig();
    
    if ([self lockScreenScrollView] && [[self lockScreenScrollView] isKindOfClass:%c(SBLockScreenScrollView)]){
        
        SBLockScreenScrollView *lsScrollView = ( SBLockScreenScrollView *)[self lockScreenScrollView];
        
        UIImageView *lsMediaArtworkView = [lsScrollView mediaArtworkView];
        
        if (lsMediaArtworkView){
            
            if ([self mediaControlsViewController]){
                
                CGFloat newArtworkYValue = 20; //status bar height
                //we add our Acapella view to the superview, so we will use that view to calulate
                newArtworkYValue += [[self mediaControlsViewController] mediaControlsView].superview.frame.origin.x +
                [[self mediaControlsViewController] mediaControlsView].superview.frame.size.height;
                //[[self mediaControlsViewController] mediaControlsView].superview.backgroundColor = [UIColor redColor];
                
                [lsMediaArtworkView setOriginY:newArtworkYValue];
            }
            
        }
        
    }
}

%new
- (MPUSystemMediaControlsViewController *)mediaControlsViewController
{
    return MSHookIvar<MPUSystemMediaControlsViewController *>(self, "_mediaControlsViewController"); 
}

%end





#pragma mark logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




