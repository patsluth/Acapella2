

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"
#import "SWAcapellaPlaylistOptions.h"
#import "SWAcapellaShowEEActivity.h"
#import "SWAcapellaGlobalDefines.h"


#import <Springboard/Springboard.h>
#import <MediaRemote/MediaRemote.h>


#import "MPUSystemMediaControlsViewController+SW.h"
#import "_MPUSystemMediaControlsView.h" //iOS 7
#import "MPUSystemMediaControlsView.h" //iOS 8
#import "MPUMediaControlsTitlesView.h"
#import "MPUMediaControlsVolumeView.h"
#import "MPUItemOfferButton.h"
#import "SBCCMediaControlsSectionController.h"


#import "substrate.h"
#import <objc/runtime.h>
#import "dlfcn.h"





#pragma mark MPUSystemMediaControlsViewController

static SWAcapellaBase *_acapella;
static UIActivityViewController *_acapellaSharingActivityView;
static SWAcapellaPlaylistOptions *_acapellaPlaylistOptions;

static NSDictionary *_previousNowPlayingInfo;

static UIColor *_acapellaTintColor;





@interface MPUSystemMediaControlsViewController()
{
}

@property (strong, nonatomic) UIActivityViewController *acapellaSharingActivityView;
@property (strong, nonatomic) SWAcapellaPlaylistOptions *acapellaPlaylistOptions;

@property (strong, nonatomic) NSDictionary *previousNowPlayingInfo;

@property (strong, nonatomic) UIColor *acapellaTintColor;

- (void)updateRepeatButtonToMediaRepeatMode:(int)repeatMode;
- (void)updateShuffleButtonToMediaShuffleMode:(int)shuffleMode;

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
- (UIView *)transportControlsView
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
    
    if ([SWDeviceInfo iOSVersion_First] != 8){
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
    
    if ([SWDeviceInfo iOSVersion_First] != 8){
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
- (SWAcapellaPlaylistOptions *)acapellaPlaylistOptions
{
    return objc_getAssociatedObject(self, &_acapellaPlaylistOptions);
}

%new
- (void)setAcapellaPlaylistOptions:(SWAcapellaPlaylistOptions *)acapellaPlaylistOptions
{
    objc_setAssociatedObject(self, &_acapellaPlaylistOptions, acapellaPlaylistOptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

%new
- (UIColor *)acapellaTintColor
{
    UIColor *atc = objc_getAssociatedObject(self, &_acapellaTintColor);
    
    if (!atc){
        return self.view.window.tintColor;
    }
    
    return atc;
}

%new
- (void)setAcapellaTintColor:(UIColor *)acapellaTintColor
{
    objc_setAssociatedObject(self, &_acapellaTintColor, acapellaTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        
        if (!self.acapellaPlaylistOptions){
            self.acapellaPlaylistOptions = [[%c(SWAcapellaPlaylistOptions) alloc] init];
            self.acapellaPlaylistOptions.delegate = self;
        }
        
        self.acapella.frame = mediaControlsView.frame;
        [mediaControlsView.superview addSubview:self.acapella];
        
        [self trackInformationView].userInteractionEnabled = NO;
        
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
    
    [self revertUI:nil]; //set colours to default
    
    MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaRemoteNowPlayingInfoDidChangeNotification)
                                                 name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                               object:nil];
    
    //ColorFlow
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(revertUI:)
                                                 name:@"ColorFlowLockScreenColorReversionNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(colorizeUI:)
                                                 name:@"ColorFlowLockScreenColorizationNotification"
                                               object:nil];
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
    
    [self.acapellaPlaylistOptions cleanup];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                                  object:nil];
    
    MRMediaRemoteUnregisterForNowPlayingNotifications();
    
    //ColorFlow
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ColorFlowLockScreenColorReversionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ColorFlowLockScreenColorizationNotification" object:nil];
}

#pragma mark ColorFlow

%new
- (void)revertUI:(NSNotification *)notification
{
    if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
        
        MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
        self.acapellaTintColor = [titles _titleLabel].textColor;
        
    } else {
        
        self.acapellaTintColor = [UIColor blackColor];
        
    }
}

%new
- (void)colorizeUI:(NSNotification *)notification
{
    if ([self.view.window.rootViewController isKindOfClass:%c(SBControlCenterController)]){
        
        if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
            
            MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
            self.acapellaTintColor = [titles _titleLabel].textColor;
            
        }
        
        return;
        
    }
    
    if (!notification || !notification.userInfo){
        [self revertUI:nil];
        return;
    }
    
    //UIColor *backgroundColor = userInfo[@"BackgroundColor"];
    //UIColor *primaryColor = userInfo[@"PrimaryColor"];
    //UIColor *secondaryColor = userInfo[@"SecondaryColor"];
    //BOOL isBackgroundDark = [userInfo[@"IsBackgroundDark"] boolValue];
    
    self.acapellaTintColor = notification.userInfo[@"PrimaryColor"];
    
    //update to the new colours if we are showing
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        if (resultDict && self.acapellaPlaylistOptions && [self.acapellaPlaylistOptions created]){
            
            int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
            int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
            
            [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
            [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
            
        }
        
    });
}

#pragma mark MediaRemote

%new
- (void)mediaRemoteNowPlayingInfoDidChangeNotification
{
    if (!self.view.window){
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
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (!self.acapella.scrollview.isAnimating){
                            [self.acapella.scrollview finishWrapAroundAnimation];
                        }
                    }];
                    
                } else {
                    
                    NSNumber *elapsedTime = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime];
                    
                    if (elapsedTime && [elapsedTime doubleValue] <= 0.0){ //restarted the song
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (!self.acapella.scrollview.isAnimating){
                                [self.acapella.scrollview finishWrapAroundAnimation];
                            }
                        }];
                        
                    }
                    
                }
            } else { //3rd party apps, which have no UID's
                
                NSString *itemTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                NSString *previousItemTitle;
                
                if (self.previousNowPlayingInfo){
                    previousItemTitle = [self.previousNowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                }
                
                if (!previousItemTitle || (previousItemTitle && ![itemTitle isEqualToString:previousItemTitle])){ //new song
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (!self.acapella.scrollview.isAnimating){
                            [self.acapella.scrollview finishWrapAroundAnimation];
                        }
                    }];
                    
                } else {
                    
                    NSNumber *elapsedTime = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime];
                    
                    if (elapsedTime && [elapsedTime doubleValue] <= 0.0){ //restarted the song
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (!self.acapella.scrollview.isAnimating){
                                [self.acapella.scrollview finishWrapAroundAnimation];
                            }
                        }];
                        
                    }
                    
                }
                
            }
        } else {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (!self.acapella.scrollview.isAnimating){
                    [self.acapella.scrollview finishWrapAroundAnimation];
                }
            }];
            
        }
        
        self.previousNowPlayingInfo = resultDict;
        
    });
}

#pragma mark SWAcapellaDelegate

%new
- (UIImage *)swAcapellaImageForPullToRefreshControl
{
    UIImage *returnVal;
    
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/AcapellaSupport.bundle"];
    
    if (bundle){
        returnVal = [UIImage
                     imageWithContentsOfFile:[bundle
                                              pathForResource:@"Acapella_Pull_To_Refresh_Image" ofType:@"png"]];
        returnVal = [returnVal imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    return returnVal;
}

%new
- (UIColor *)swAcapellaTintColorForPullToRefreshControl
{
    return self.acapellaTintColor;
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
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    swAcapellaAction action;
    
    if ([view respondsToSelector:@selector(stopWrapAroundFallback)]){
        [view stopWrapAroundFallback];
    }
    
    if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:(direction == SW_SCROLL_DIR_LEFT) ?
                                                           @"swipeLeftAction" : @"swipeRightAction"
                                                                                defaultValue:(direction == SW_SCROLL_DIR_LEFT) ?
                                                           @3 : @2]
                                             withDelegate:self];
        
    } else if (direction == SW_SCROLL_DIR_UP) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeUpAction" defaultValue:@7]
                                             withDelegate:self];
        
    } else if (direction == SW_SCROLL_DIR_DOWN) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeDownAction" defaultValue:@6]
                                             withDelegate:self];
        
    }
    
    if (action){
        action();
    } else {
        if ([view respondsToSelector:@selector(finishWrapAroundAnimation)]){
            [view finishWrapAroundAnimation];
        }
    }
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

%new
- (void)swAcapella:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIView *mediaControlsView = [self mediaControlsView];
    
    if (mediaControlsView){
        
        if (indexPath.section == 0){
            switch (indexPath.row){
                case 0:
                    
                    if ([self volumeView].superview){
                        [[self volumeView] removeFromSuperview];
                    }
                    
                    if ([self timeInformationView]){
                        [cell addSubview:[self timeInformationView]];
                    }
                    
                    break;
                    
                case 1:
                    
                    if ([self trackInformationView] && view.scrollview){
                        [view.scrollview addSubview:[self trackInformationView]];
                    }
                    
                    break;
                    
                case 2:
                    
                    if ([self timeInformationView].superview){
                        [[self timeInformationView] removeFromSuperview];
                    }
                    
                    if ([self volumeView]){
                        [cell addSubview:[self volumeView]];
                    }
                    
                    break;
                    
                default:
                    break;
            }
        }
        
        [mediaControlsView layoutSubviews];
        
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark Actions

%new
- (void)action_PlayPause
{
    [SWAcapellaActionsHelper action_PlayPause:^(BOOL successful, id object){
        if (successful){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 self.acapella.tableview.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      self.acapella.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      self.acapella.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
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
    [SWAcapellaActionsHelper action_NextSong:^(BOOL successful, id object){
        if (!object){
            [self.acapella.scrollview finishWrapAroundAnimation];
        } else {
            [self.acapella.scrollview startWrapAroundFallback];
        }
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
        
        if (object){
            
            SWAcapellaShowEEActivity *showEE;
            
            if ([self.view.superview isKindOfClass:NSClassFromString(@"SBEqualizerScrollView")]){
                showEE = [[SWAcapellaShowEEActivity alloc] init];
            }
            
            self.acapellaSharingActivityView = [[UIActivityViewController alloc] initWithActivityItems:object
                                                                                 applicationActivities:(showEE != nil) ? @[showEE] : nil];
            
            NSMutableArray *excludedActivityTypes = [[NSMutableArray alloc] init];
            
            [excludedActivityTypes addObjectsFromArray:@[UIActivityTypePrint,
                                                         UIActivityTypeAssignToContact,
                                                         UIActivityTypeSaveToCameraRoll,
                                                         UIActivityTypeAddToReadingList,
                                                         @"com.linkedin.LinkedIn.ShareExtension",
                                                         @"com.6wunderkinder.wunderlistmobile.sharingextension",
                                                         @"com.flexibits.fantastical2.iphone.add"]];
            
            if (!successful){ //device is locked
                
                                [excludedActivityTypes addObjectsFromArray:@[UIActivityTypePostToFacebook,
                                                                             UIActivityTypePostToTwitter,
                                                                             UIActivityTypePostToWeibo,
                                                                             UIActivityTypeMessage,
                                                                             UIActivityTypeMail,
                                                                             UIActivityTypePostToFlickr,
                                                                             UIActivityTypePostToVimeo,
                                                                             UIActivityTypePostToTencentWeibo]];
            }
            
            self.acapellaSharingActivityView.excludedActivityTypes = excludedActivityTypes;
            
            [self presentViewController:self.acapellaSharingActivityView animated:YES completion:nil];
            
            __block MPUSystemMediaControlsViewController *blockSelf = self;
            
            self.acapellaSharingActivityView.completionHandler = ^(NSString *activityType, BOOL completed){
                
                if (blockSelf){
                    
                    if ([activityType isEqualToString:SWAcapellaShowEEActivityType]){
                        
                        [blockSelf.acapella.tableview resetContentOffset:NO];
                        UIScrollView *eeScrollView = (UIScrollView *)blockSelf.view.superview;
                        [eeScrollView setContentOffset:CGPointMake(eeScrollView.frame.size.width, 0.0)];
                        
                    } else {
                        
                        [blockSelf.acapella.tableview resetContentOffset:YES];
                        
                    }
                    
                }
            };
            
        } else {
            
            [self.acapella.tableview resetContentOffset:YES];
            
        }
    }];
}

%new
- (void)action_ShowPlaylistOptions
{
    [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
        
        NSDictionary *resultDict = object;
        
        if (resultDict && self.acapellaPlaylistOptions && ![self.acapellaPlaylistOptions created]){
            
            int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
            int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
            
            [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
            [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
            
            [self.acapellaPlaylistOptions create];
            [self.acapellaPlaylistOptions layoutToScrollView:self.acapella.scrollview];
            [self.acapella.scrollview stopWrapAroundFallback];
            [self.acapella.scrollview resetContentOffset:NO];
            [self.acapella.tableview resetContentOffset:YES];
            [self.acapellaPlaylistOptions startHideTimer];
            
        } else {
        
            [self.acapellaPlaylistOptions cleanup];
            [self.acapella.tableview resetContentOffset:YES];
            
        }
        
    }];
}

%new
- (void)action_OpenApp
{
    [SWAcapellaActionsHelper action_OpenApp:nil];
}

%new
- (void)action_ShowRatingsOpenApp
{
    [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
        if (successful){
            [self _likeBanButtonTapped:nil];
        } else {
            [SWAcapellaActionsHelper action_OpenApp:nil];
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

#pragma mark SWAcapellaPlaylistOptions

%new
- (void)updateRepeatButtonToMediaRepeatMode:(int)repeatMode
{
    if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
        
        MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSString *newText;
            UIColor *newButtonColor = [UIColor clearColor];
            UIColor *newTextColor = [UIColor clearColor];
            
            if (repeatMode == 0){
                newText = @" Repeat Off ";
                newButtonColor = [UIColor clearColor];
                newTextColor = self.acapellaTintColor;
            } else if (repeatMode == 1){
                newText = @" Repeat One ";
                newButtonColor = self.acapellaTintColor;
                newTextColor = [UIColor blackColor];
            } else if (repeatMode == 2){
                newText = @" Repeat All ";
                newButtonColor = self.acapellaTintColor;
                newTextColor = [UIColor blackColor];
            }
            
            [self.acapellaPlaylistOptions updateButtonAtIndex:0
                                                         text:newText
                                                         font:[titles _detailLabel].font
                                                 buttonColour:newButtonColor
                                                   textColour:newTextColor];
            
            [self.acapellaPlaylistOptions layoutToScrollView:self.acapella.scrollview];
            
        }];
    }
}

%new
- (void)updateShuffleButtonToMediaShuffleMode:(int)shuffleMode
{
    if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
        
        MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSString *newText;
            UIColor *newButtonColor = [UIColor clearColor];
            UIColor *newTextColor = [UIColor clearColor];
            
            if (shuffleMode == 0){
                newText = @" Shuffle ";
                newButtonColor = [UIColor clearColor];
                newTextColor = self.self.acapellaTintColor;
            } else if (shuffleMode == 2){
                newText = @" Shuffle All ";
                newButtonColor = self.acapellaTintColor;
                newTextColor = [UIColor blackColor];
            }
            
            [self.acapellaPlaylistOptions updateButtonAtIndex:2
                                                         text:newText
                                                         font:[titles _detailLabel].font
                                                 buttonColour:newButtonColor
                                                   textColour:newTextColor];
            
            [self.acapellaPlaylistOptions layoutToScrollView:self.acapella.scrollview];
            
        }];
    }
}

#pragma mark SWAcapellaPlaylistOptionsDelegate
%new
- (void)swAcapellaPlaylistOptions:(SWAcapellaPlaylistOptions *)view buttonTapped:(UIButton *)button withIndex:(NSInteger)index
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        if (result){
            NSDictionary *resultDict = (__bridge NSDictionary *)result;
            
            if (index == 0){
                
                int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
                mediaRepeatMode = ((mediaRepeatMode + 1) > 2) ? 0 : mediaRepeatMode + 1;
                MRMediaRemoteSetRepeatMode(mediaRepeatMode);
                [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
                
            } else if (index == 2){
                
                int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
                mediaShuffleMode = (mediaShuffleMode == 0) ? 2 : 0; //0 is off, 2 is on
                MRMediaRemoteSetShuffleMode(mediaShuffleMode);
                [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
                
            }
            
        }
    });
}

%end





#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return CGSizeMake(original.width, original.height * 0.90);
    }
    
    return original;
}

%end

%hook _MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    
    UIView *time = MSHookIvar<UIView *>(self, "_timeInformationView");
    UIView *volume = MSHookIvar<UIView *>(self, "_volumeView");
    
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if (time && ([time.superview isKindOfClass:[UITableViewCell class]] ||
                   [time.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        [time setCenter:CGPointMake(time.superview.frame.size.width / 2,
                                    time.superview.frame.size.height / 2)];
        
    }
    
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if (volume && ([volume.superview isKindOfClass:[UITableViewCell class]] ||
                   [volume.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        [volume setCenter:CGPointMake(volume.superview.frame.size.width / 2,
                                      volume.superview.frame.size.height / 2)];
        
    }
}

%end

%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    
    UIView *time = MSHookIvar<UIView *>(self, "_timeInformationView");
    UIView *volume = MSHookIvar<UIView *>(self, "_volumeView");
    
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if (time && time.superview && ([time.superview isKindOfClass:[UITableViewCell class]] ||
                                   [time.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        [time setCenter:CGPointMake(time.superview.frame.size.width / 2,
                                    time.superview.frame.size.height / 2)];
        
    }
    
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if (volume  && volume.superview && ([volume.superview isKindOfClass:[UITableViewCell class]] ||
                                        [volume.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        [volume setCenter:CGPointMake(volume.superview.frame.size.width / 2,
                                      volume.superview.frame.size.height / 2)];
        
    }
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

//%hook SLComposeServiceViewController
//
//- (void)viewWillAppear:(BOOL)arg1
//{
//    %orig(arg1);
//}
//
//%end

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




