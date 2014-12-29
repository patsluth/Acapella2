

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"
#import "SWAcapellaPlaylistOptions.h"
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
static UIActivityViewController *_acapellaSharingActivityView;
static SWAcapellaPlaylistOptions *_acapellaPlaylistOptions;





@interface MusicNowPlayingViewController()
{
}

@property (strong, nonatomic) UIActivityViewController *acapellaSharingActivityView;
@property (strong, nonatomic) SWAcapellaPlaylistOptions *acapellaPlaylistOptions;

- (void)updateRepeatButtonToMediaRepeatMode:(int)repeatMode;
- (void)updateCreateButton;
- (void)updateShuffleButtonToMediaShuffleMode:(int)shuffleMode;

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
- (UIView *)geniusButton
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_geniusButton");
    }
    
    return nil;
}

%new
- (UIButton *)createButton
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIButton *>([self playbackControlsView], "_createButton");
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
        
        if ([self repeatButton]){
            [[self repeatButton] removeFromSuperview];
        }
        
        if ([self geniusButton]){
            [[self geniusButton] removeFromSuperview];
        }
        
        if ([self createButton]){
            [self createButton].alpha = 0.0;
        }
        
        if ([self shuffleButton]){
            [[self shuffleButton] removeFromSuperview];
        }
        
        if ([self artworkView]){
            
            if (!self.acapella){
                self.acapella = [[%c(SWAcapellaBase) alloc] init];
                self.acapella.delegateAcapella = self;
            }
            
            if (!self.acapellaPlaylistOptions){
                self.acapellaPlaylistOptions = [[%c(SWAcapellaPlaylistOptions) alloc] init];
                self.acapellaPlaylistOptions.delegate = self;
                self.acapellaPlaylistOptions.shouldShowGeniusButton = YES;
            }
            
            CGFloat artworkBottomYOrigin = [self artworkView].frame.origin.y + [self artworkView].frame.size.height;
            //set the bottom acapella origin to the top of the repeat button. Set it to the bottom of the view if repeat button hasnt been set up yet.
            CGFloat bottomAcapellaYOrigin = [self playbackControlsView].frame.origin.y +
                                             [self playbackControlsView].frame.size.height
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
            [[self playbackControlsView] bringSubviewToFront:[self createButton]];
            
            if (self.acapella.tableview){
                if ([self.acapella.tableview numberOfSections] > 0 && [self.acapella.tableview numberOfRowsInSection:0] > 2){
                    
                    [self.acapella.tableview beginUpdates];
                    
                    [self.acapella.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],
                                                                      [NSIndexPath indexPathForRow:2 inSection:0]]
                                                   withRowAnimation:UITableViewRowAnimationNone];
                    
                    [self.acapella.tableview endUpdates];
                    
                }
            }
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
    return self.navigationController.navigationBar.tintColor;;
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
                    
                    if ([self volumeSlider].superview){
                        [[self volumeSlider] removeFromSuperview];
                    }
                    
                    if ([self progressControl]){
                        [cell addSubview:[self progressControl]];
                        [[self progressControl] setFrame:[self progressControl].frame];
                    }
                    
                    break;
                    
                case 1:
                    
                    [view.scrollview addSubview:[self titlesView]];
                    [[self titlesView] setFrame:[self titlesView].frame];
                    
                    break;
                    
                case 2:
                    
                    if ([self progressControl].superview){
                        [[self progressControl] removeFromSuperview];
                    }
                    
                    if ([self volumeSlider]){
                        [cell addSubview:[self volumeSlider]];
                        [[self volumeSlider] setFrame:[self volumeSlider].frame];
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
                        
                        if (mediaCurrentElapsedDuration >= 2.0 || mediaCurrentElapsedDuration <= 0.0){
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self.acapella.scrollview finishWrapAroundAnimation];
                            }];
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
            
            self.acapellaSharingActivityView = [[UIActivityViewController alloc] initWithActivityItems:object applicationActivities:nil];
            
            self.acapellaSharingActivityView.excludedActivityTypes = @[UIActivityTypePrint,
                                                                       UIActivityTypeAssignToContact,
                                                                       UIActivityTypeSaveToCameraRoll,
                                                                       UIActivityTypeAddToReadingList,
                                                                       @"com.linkedin.LinkedIn.ShareExtension",
                                                                       @"com.6wunderkinder.wunderlistmobile.sharingextension",
                                                                       @"com.flexibits.fantastical2.iphone.add"];
            
            [self presentViewController:self.acapellaSharingActivityView animated:YES completion:nil];
            
            __block MusicNowPlayingViewController *blockSelf = self;
            
            self.acapellaSharingActivityView.completionHandler = ^(NSString *activityType, BOOL completed){
                
                if (blockSelf){
                    
                    [blockSelf.acapella.tableview resetContentOffset:YES];
                    
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
        
        if (!successful && resultDict && self.acapellaPlaylistOptions && ![self.acapellaPlaylistOptions created]){
            
            int mediaRepeatMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRepeatMode] intValue];
            int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
            
            [self updateRepeatButtonToMediaRepeatMode:mediaRepeatMode];
            [self updateCreateButton];
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

#pragma mark SWAcapellaPlaylistOptions

%new
- (void)updateRepeatButtonToMediaRepeatMode:(int)repeatMode
{
    if ([self titlesView] && [[self titlesView] isKindOfClass:%c(MPUNowPlayingTitlesView)]){
        
        MPUNowPlayingTitlesView *titles = (MPUNowPlayingTitlesView *)[self titlesView];
        
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
                newButtonColor = self.navigationController.navigationBar.tintColor;
                newTextColor = [UIColor blackColor];
            } else if (repeatMode == 2){
                newText = @" Repeat All ";
                newButtonColor = self.navigationController.navigationBar.tintColor;
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
- (void)updateCreateButton
{
    if ([self titlesView] && [[self titlesView] isKindOfClass:%c(MPUNowPlayingTitlesView)]){
        
        MPUNowPlayingTitlesView *titles = (MPUNowPlayingTitlesView *)[self titlesView];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.acapellaPlaylistOptions updateButtonAtIndex:1
                                                         text:@"Create"
                                                         font:[titles _detailLabel].font
                                                 buttonColour:[UIColor clearColor]
                                                   textColour:[titles _titleLabel].textColor];
            
            [self.acapellaPlaylistOptions layoutToScrollView:self.acapella.scrollview];
        }];
    }
}

%new
- (void)updateShuffleButtonToMediaShuffleMode:(int)shuffleMode
{
    if ([self titlesView] && [[self titlesView] isKindOfClass:%c(MPUNowPlayingTitlesView)]){
        
        MPUNowPlayingTitlesView *titles = (MPUNowPlayingTitlesView *)[self titlesView];
        
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
                newButtonColor = self.navigationController.navigationBar.tintColor;
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
                
            } else if (index == 1){
                
                SEL createSelector = NSSelectorFromString(@"_createAction:");
                
                if ([[self playbackControlsView] respondsToSelector:createSelector]){
                    [[self playbackControlsView] performSelectorOnMainThread:createSelector
                                                                  withObject:[self createButton]
                                                               waitUntilDone:NO];
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.acapellaPlaylistOptions cleanup];
                    }];
                }
                
            } else if (index == 2){
                
                int mediaShuffleMode = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoShuffleMode] intValue];
                mediaShuffleMode = (mediaShuffleMode == 0) ? 2 : 0; //0 is off, 2 is on
                MRMediaRemoteSetShuffleMode(mediaShuffleMode);
                [self updateShuffleButtonToMediaShuffleMode:mediaShuffleMode];
                
            }
            
        }
    });
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





#pragma mark MPDetailSlider

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





#pragma mark MPVolumeSlider

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




