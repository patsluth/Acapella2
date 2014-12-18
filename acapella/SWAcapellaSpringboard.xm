

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"
#import "SWAcapellaPlaylistOptions.h"
#import "SWAcapellaGlobalDefines.h"

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

#import "substrate.h"
#import <objc/runtime.h>
#import "dlfcn.h"





#pragma mark MPUSystemMediaControlsViewController

static SWAcapellaBase *_acapella;
static UIActivityViewController *_acapellaSharingActivityView;
static SWAcapellaPlaylistOptions *_acapellaPlaylistOptions;




@interface MPUSystemMediaControlsViewController()
{
}

@property (strong, nonatomic) UIActivityViewController *acapellaSharingActivityView;
@property (strong, nonatomic) SWAcapellaPlaylistOptions *acapellaPlaylistOptions;

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
- (SWAcapellaPlaylistOptions *)acapellaPlaylistOptions
{
    return objc_getAssociatedObject(self, &_acapellaPlaylistOptions);
}

%new
- (void)setAcapellaPlaylistOptions:(SWAcapellaPlaylistOptions *)acapellaPlaylistOptions
{
    objc_setAssociatedObject(self, &_acapellaPlaylistOptions, acapellaPlaylistOptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    UIColor *returnVal = [UIColor yellowColor];
    
    if ([self trackInformationView] && [[self trackInformationView] isKindOfClass:%c(MPUMediaControlsTitlesView)]){
        
        MPUMediaControlsTitlesView *titles = (MPUMediaControlsTitlesView *)[self trackInformationView];
        returnVal = [titles _titleLabel].textColor;
        
    }
    
    return returnVal;
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
                                                           valueForKey:@"swipeUpAction" defaultValue:@6]
                                             withDelegate:self];
        
    } else if (direction == SW_SCROLL_DIR_DOWN) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeDownAction" defaultValue:@7]
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
            if (successful){
                [self.acapella.scrollview finishWrapAroundAnimation]; //make sure we wrap around on iTunes Radio
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
        if (!successful){
            if (object && [object isKindOfClass:%c(SBDeviceLockController)]){
                
                __block SWAcapellaTableView *blockTableView = self.acapella.tableview;
                
                [[[SWUIAlertView alloc] initWithTitle:@"Acapella"
                                              message:@"Your device must be unlocked to bring up the activity screen for security reasons. Unlock device and try again."
                                   clickedButtonBlock:^(UIAlertView *alert, NSInteger buttonIndex){
                                   }
                                      didDismissBlock:^(UIAlertView *alert, NSInteger buttonIndex){
                                          if (blockTableView){
                                              [blockTableView resetContentOffset:YES];
                                          }
                                      }
                                    cancelButtonTitle:@":(-+--<" otherButtonTitles:nil] show];
                
            } else {
                [self.acapella.tableview resetContentOffset:YES];
            }
        } else {
            
            self.acapellaSharingActivityView = object;
            [self presentViewController:self.acapellaSharingActivityView animated:YES completion:nil];
            
            __block SWAcapellaTableView *blockTableView = self.acapella.tableview;
            
            self.acapellaSharingActivityView.completionHandler = ^(NSString *activityType, BOOL completed){
                if (blockTableView){
                    [blockTableView resetContentOffset:YES];
                }
            };
            
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
                newTextColor = [titles _titleLabel].textColor;
            } else if (repeatMode == 1){
                newText = @" Repeat One ";
                newButtonColor = [titles _titleLabel].textColor;
                newTextColor = [titles _detailLabel].textColor;
            } else if (repeatMode == 2){
                newText = @" Repeat All ";
                newButtonColor = [titles _titleLabel].textColor;
                newTextColor = [titles _detailLabel].textColor;
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
                newTextColor = [titles _titleLabel].textColor;
            } else if (shuffleMode == 2){
                newText = @" Shuffle All ";
                newButtonColor = [titles _titleLabel].textColor;
                newTextColor = [titles _detailLabel].textColor;
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





#pragma mark MPUSystemMediaControlsView

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

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




