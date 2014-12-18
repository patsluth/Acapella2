

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"
#import "SWAcapellaGlobalDefines.h"

#import <MediaRemote/MediaRemote.h>

#import "MusicNowPlayingViewController+SW.h"
#import "MPAVController.h"
#import "MPAVItem.h"
#import "MPUNowPlayingTitlesView.h"
#import "MPDetailSlider.h"
#import "MPVolumeSlider.h"

#import "substrate.h"
#import <objc/runtime.h>





#pragma mark MusicNowPlayingViewController

static SWAcapellaBase *_acapella;
static UIButton *_acapellaRepeatButton;
static UIButton *_acapellaGeniusButton;
static UIButton *_acapellaShuffleButton;
static UIActivityViewController *_acapellaSharingActivityView;





@interface MusicNowPlayingViewController()
{
}

@property (strong, nonatomic) UIActivityViewController *acapellaSharingActivityView;

- (void)startRatingShouldHideTimer;
- (void)hideRatingControlWithTimer;

@end





%hook MusicNowPlayingViewController

#pragma mark Helper

%new
- (UIView *)playbackControlsView
{
    return MSHookIvar<UIView *>(self, "_playbackControlsView");
}

%new
- (MPAVController *)player
{
    if ([self playbackControlsView]){
        return MSHookIvar<MPAVController *>([self playbackControlsView], "_player");
    }
    
    return nil;
}

%new
- (UISlider *)progressControl
{
    if ([self playbackControlsView]){
        return MSHookIvar<UISlider *>([self playbackControlsView], "_progressControl");
    }
    
    return nil;
}

%new
- (UIView *)transportControls
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_transportControls");
    }
    
    return nil;
}

%new
- (UISlider *)volumeSlider
{
    if ([self playbackControlsView]){
        return MSHookIvar<UISlider *>([self playbackControlsView], "_volumeSlider");
    }
    
    return nil;
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
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_repeatButton");
    }
    
    return nil;
}

%new
- (UIView *)shuffleButton
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_shuffleButton");
    }
    
    return nil;
}

%new
- (UIView *)geniusButton
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_geniusButton");
    }
    
    return nil;
}

%new
- (UIImageView *)artworkView
{
    UIView *artwork = MSHookIvar<UIView *>(self, "_contentView");
    
    if (artwork && [artwork isKindOfClass:[UIImageView class]]){
        return (UIImageView *)artwork;
    }
    
    return nil;
}

%new
- (MPAVItem *)mpavItem
{
    return MSHookIvar<MPAVItem *>(self, "_item");
}

%new
- (UIButton *)likeOrBanButton
{
    if ([self transportControls]){
        return MSHookIvar<UIButton *>([self transportControls], "_likeOrBanButton");
    }
    
    return nil;
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
- (NSDictionary *)lastNowPlayingInfo
{
    return objc_getAssociatedObject(self, &_lastNowPlayingInfo);
}

%new
- (void)setLastNowPlayingInfo:(NSDictionary *)lastNowPlayingInfo
{
    objc_setAssociatedObject(self, &_lastNowPlayingInfo, lastNowPlayingInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Init

- (void)viewDidLoad
{
    %orig();
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    if ([self playbackControlsView]){
        
        if ([self progressControl] && [self progressControl].superview == [self playbackControlsView]){
            [[self progressControl] removeFromSuperview];
        }
        
        if ([self transportControls] && [self transportControls].superview == [self playbackControlsView]){
            [[self transportControls] removeFromSuperview];
        }
        
        if ([self volumeSlider] && [self volumeSlider].superview == [self playbackControlsView]){
            [[self volumeSlider] removeFromSuperview];
        }
        
        if ([self titlesView] && [self titlesView].superview && ![[self titlesView].superview isKindOfClass:[UIScrollView class]]){
            [[self titlesView] removeFromSuperview];
        }
        
        if ([self artworkView]){
            
            if (!self.acapella){
                self.acapella = [[%c(SWAcapellaBase) alloc] init];
                self.acapella.delegateAcapella = self;
            }
            
            if (([self progressControl] && [self progressControl].isTracking) || ([self volumeSlider] && [self volumeSlider].isTracking)){
                return;
            }
            
            CGFloat artworkBottomYOrigin = [self artworkView].frame.origin.y + [self artworkView].frame.size.height;
            //set the bottom acapella origin to the top of the repeat button. Set it to the bottom of the view if repeat button hasnt been set up yet.
            CGFloat bottomAcapellaYOrigin = (([self repeatButton].frame.origin.y <= 0.0) ?
                                             [self playbackControlsView].frame.origin.y + [self playbackControlsView].frame.size.height :
                                             [self repeatButton].frame.origin.y)
            - artworkBottomYOrigin;
            
            self.acapella.frame = CGRectMake([self playbackControlsView].frame.origin.x,
                                             artworkBottomYOrigin,
                                             //the space between the bottom of the artowrk and the bottom of the screen
                                             [self playbackControlsView].frame.size.width,
                                             bottomAcapellaYOrigin);
            
            if ([self ratingControl]){
                [self ratingControl].frame = self.acapella.frame;
            }
            
            [[self playbackControlsView] addSubview:self.acapella];
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
    
//    MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul));
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(nowPlayingInfoDidChangeNotification)
//                                                 name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
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
    
   // MRMediaRemoteUnregisterForNowPlayingNotifications();
}

/*
 - (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2
 {
 %orig(arg1, arg2);
 
 [self viewDidLayoutSubviews];
 }
 
 - (void)didRotateFromInterfaceOrientation:(int)arg1
 {
 %orig(arg1);
 
 [self viewDidLayoutSubviews];
 }
 */

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
    
    if ([self titlesView] && [[self titlesView] isKindOfClass:%c(MPUNowPlayingTitlesView)]){
        
        MPUNowPlayingTitlesView *titles = (MPUNowPlayingTitlesView *)[self titlesView];
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
    if ([self playbackControlsView]){
        
        if (indexPath.section == 0){
            switch (indexPath.row){
                case 0:
                    
                    if ([self volumeSlider].superview == cell){
                        [[self volumeSlider] removeFromSuperview];
                    }
                    
                    if ([self progressControl]){
                        [cell addSubview:[self progressControl]];
                        [[self progressControl] setFrame:[self progressControl].frame]; //update our frame because are forcing centre in setRect:
                    }
                    
                    break;
                    
                case 1:
                    
                    [view.scrollview addSubview:[self titlesView]];
                    [[self titlesView] setFrame:[self titlesView].frame]; //update our frame because are forcing centre in setRect:
                    
                    break;
                    
                case 2:
                    
                    if ([self progressControl].superview == cell){
                        [[self progressControl] removeFromSuperview];
                    }
                    
                    if ([self volumeSlider]){
                        [cell addSubview:[self volumeSlider]];
                        [[self volumeSlider] setFrame:[self volumeSlider].frame]; //update our frame because are forcing centre in setRect:
                    }
                    
                    break;
                    
                default:
                    break;
            }
        }
        
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark Actions

%new
- (void)nowPlayingInfoDidChangeNotification
{
//    [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
//        
//        NSDictionary *resultDict = object;
//        
//        if (self.lastNowPlayingInfo && self.acapella && self.acapella.scrollview){
//            
//            NSNumber *lastTrackUniqueID = [self.lastNowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier];
//            NSNumber *newTrackUniqueID = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier];
//            
//            if (lastTrackUniqueID && newTrackUniqueID && [lastTrackUniqueID isEqualToNumber:newTrackUniqueID]){
//                
//                //double lastTrackElapsedTime = [[self.lastNowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
//                //double newTrackElapsedTime = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
//                
//                //double trackDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDuration] doubleValue];
//                
//                //CGFloat percentageDifference = fabsf((lastTrackElapsedTime / trackDuration) - (newTrackElapsedTime / trackDuration));
//                
//                [self.acapella.scrollview finishWrapAroundAnimation];
//                
//            } else {
//                [self.acapella.scrollview finishWrapAroundAnimation];
//            }
//            
//        } else {
//            //[self.acapella.scrollview resetContentOffset:NO];
//        }
//        
//        self.lastNowPlayingInfo = resultDict;
//        
//    }];
}

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
            } else {
                
                MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
                    
                    NSDictionary *resultDict = (__bridge NSDictionary *)result;
                    
                    if (resultDict){
                        double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
                        
                        if (mediaCurrentElapsedDuration >= 2.5 || mediaCurrentElapsedDuration <= 0.0){
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self.acapella.scrollview finishWrapAroundAnimation];
                            }];
                        }
                    }
                    
                });
            }
        }];
        
        //self.lastNowPlayingInfo = object;
    }];
}

%new
- (void)action_NextSong
{
    [SWAcapellaActionsHelper action_NextSong:^(BOOL successful, id object){
        //self.lastNowPlayingInfo = object;
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
        
        if (successful){
            
            self.acapellaSharingActivityView = object;
            [self presentViewController:self.acapellaSharingActivityView animated:YES completion:nil];
            
            __block SWAcapellaTableView *blockTableView = self.acapella.tableview;
            
            self.acapellaSharingActivityView.completionHandler = ^(NSString *activityType, BOOL completed){
                if (blockTableView){
                    [blockTableView resetContentOffset:YES];
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
    [self.acapella.tableview resetContentOffset:YES];
    
    //    [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
    //
    //        NSDictionary *resultDict = object;
    //
    //        if (!successful && resultDict){
    //
    //            if (!self.acapellaRepeatButton && !self.acapellaShuffleButton){
    //
    //                self.acapellaRepeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //                [[self.acapellaRepeatButton layer] setMasksToBounds:YES];
    //                [[self.acapellaRepeatButton layer] setCornerRadius:5.0f];
    //                [self.acapellaRepeatButton addTarget:self action:@selector(acapellaRepeatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //
    //                self.acapellaShuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //                [self.acapellaShuffleButton addTarget:self action:@selector(acapellaShuffleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //                [[self.acapellaShuffleButton layer] setMasksToBounds:YES];
    //                [[self.acapellaShuffleButton layer] setCornerRadius:5.0f];
    //
    //                int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
    //                int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
    //
    //                [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
    //                [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
    //
    //                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //
    //                    [self.acapellaRepeatButton setOrigin:CGPointMake((self.acapella.scrollview.contentSize.width /
    //                                                                      [self.acapella.scrollview pagesAvailable].x) +
    //                                                                     SW_ACAPELLA_REPEATSHUFFLE_X_PADDING,
    //                                                                     (self.acapella.scrollview.contentSize.height /
    //                                                                      [self.acapella.scrollview pagesAvailable].y) - 																													self.acapellaRepeatButton.frame.size.height -
    //                                                                     SW_ACAPELLA_REPEATSHUFFLE_Y_PADDING)];
    //
    //                    [self.acapella.scrollview addSubview:self.acapellaRepeatButton];
    //
    //
    //                    [self.acapellaShuffleButton setOrigin:CGPointMake(((self.acapella.scrollview.contentSize.width /
    //                                                                        [self.acapella.scrollview pagesAvailable].x) +
    //                                                                       self.acapella.scrollview.frame.size.width) -
    //                                                                      self.acapellaShuffleButton.frame.size.width - SW_ACAPELLA_REPEATSHUFFLE_X_PADDING,
    //                                                                      self.acapellaRepeatButton.frame.origin.y)];
    //
    //                    [self.acapella.scrollview addSubview:self.acapellaShuffleButton];
    //
    //
    //
    //                    [self.acapella.scrollview stopWrapAroundFallback];
    //                    [self.acapella.scrollview resetContentOffset:NO];
    //                    [self.acapella.tableview finishWrapAroundAnimation];
    //                    [self startHideRepeatAndShuffleButtonTimer];
    //                }];
    //
    //            } else {
    //
    //                [self cleanupPlaylistOptionButtons];
    //                [self.acapella.tableview finishWrapAroundAnimation];
    //
    //            }
    //
    //        } else {
    //
    //            [self cleanupPlaylistOptionButtons];
    //            [self.acapella.tableview finishWrapAroundAnimation];
    //
    //        }
    //
    //    }];
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

#pragma mark Rating

static BOOL _didTouchRatingControl = NO;
static NSTimer *_hideRatingTimer;

- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2
{
    %orig(arg1, arg2);
    
    if (arg1){
        [self startRatingShouldHideTimer];
    } else {
        if (_hideRatingTimer){
            [_hideRatingTimer invalidate];
            _hideRatingTimer = nil;
        }
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





%hook MPDetailSlider

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if (self.superview && ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





%hook MPVolumeSlider

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if (self.superview && ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





#pragma mark logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




