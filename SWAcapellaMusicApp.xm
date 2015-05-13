
#import <Social/Social.h>

#import "libSluthware.h"
#import "NSTimer+SW.h"
#import "SWAcapella.h"
#import <AcapellaKit/AcapellaKit.h>
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"

#import "TBAlertController.h"

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

- (UIView *)mediaControlsView;
- (MPAVController *)player;
- (UIView *)progressControl;
- (UIView *)trackInformationView;
- (UIView *)transportControls;
- (UIView *)volumeView;
- (UIView *)ratingControl;
- (UIView *)repeatButton;
- (UIView *)geniusButton;
- (UIButton *)createButton;
- (UIView *)shuffleButton;
- (UIView *)artworkView;
- (MPAVItem *)mpavItem;
- (UIButton *)likeOrBanButton;

@end





%hook MusicNowPlayingViewController

%new
- (UIView *)mediaControlsView
{
    return MSHookIvar<UIView *>(self, "_playbackControlsView");
}

%new
- (MPAVController *)player
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<MPAVController *>([self mediaControlsView], "_player");
}

%new
- (UIView *)progressControl
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_progressControl");
}

%new
- (UIView *)trackInformationView
{
    return MSHookIvar<UIView *>(self, "_titlesView");
}

%new
- (UIView *)transportControls
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_transportControls");
}

%new
- (UIView *)volumeView
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_volumeSlider");
}

%new
- (UIView *)ratingControl
{
    return MSHookIvar<UIView *>(self, "_ratingControl");
}

%new
- (UIView *)repeatButton
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_repeatButton");
}

%new
- (UIView *)geniusButton
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_geniusButton");
}

%new
- (UIButton *)createButton
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIButton *>([self mediaControlsView], "_createButton");
}

%new
- (UIView *)shuffleButton
{
    if (![self mediaControlsView]){
        return nil;
    }
    
    return MSHookIvar<UIView *>([self mediaControlsView], "_shuffleButton");
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
    if (![[SWAcapellaPrefsBridge valueForKey:@"ma_enabled" defaultValue:@YES] boolValue]){
        return nil;
    }
    
    SWAcapellaBase *a = objc_getAssociatedObject(self, &_acapella);
    
    if (!a){
        
        UIView *mediaControlsView = [self mediaControlsView];
        
        if (mediaControlsView) {
            
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
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:0.0];
            [mediaControlsView addConstraint:self.acapella.heightConstraint];
            
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:self.acapella
                                                                          attribute:NSLayoutAttributeBottom
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
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
        
        if ([self artworkView]){
            
            self.acapella.heightConstraint.constant = CGRectGetMaxY(mediaControlsView.frame) - CGRectGetMaxY([self artworkView].frame);
            
            [mediaControlsView layoutIfNeeded];
            [self.acapella layoutIfNeeded];
            
        }
    }
    
    %orig(); //calling this again will ensure the titles view is centered off the bat
    
    if (self.acapella){
        
        if ([self progressControl].superview == mediaControlsView){
            [[self progressControl] removeFromSuperview];
        }
        
        if ([self volumeView].superview == mediaControlsView){
            [[self volumeView] removeFromSuperview];
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
        
        [[self ratingControl] sizeToFit];
        [self ratingControl].center = self.acapella.center;
        
        if (self.acapella.tableview){ //make sure progress and volume bars stay in cells
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

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    if (self.acapella){
        [self.acapella.tableview resetContentOffset:NO];
        [self.acapella.scrollview resetContentOffset:NO];
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
        [self.acapella.tableview resetContentOffset:NO];
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
    if (!self.acapella){
        return;
    }
    
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
    if ([self trackInformationView]){
        
        CGFloat alpha = 1.0 - (fabs(scrollView.contentOffset.y - scrollView.defaultContentOffset.y) /
                               CGRectGetMidY(scrollView.frame));
        [self trackInformationView].alpha = alpha;
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
- (void)swAcapella:(id<SWAcapellaScrollingViewProtocol>)swAcapella onSwipe:(SWScrollDirection)direction
{
    swAcapellaAction action;
    
    if (swAcapella == self.acapella.scrollview){
        [self.acapella.scrollview stopWrapAroundFallback];
    }
    
    if (direction == SWScrollDirectionLeft || direction == SWScrollDirectionRight){
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:(direction == SWScrollDirectionLeft) ?
                                                           @"swipeLeftAction" : @"swipeRightAction"
                                                                                defaultValue:(direction == SWScrollDirectionLeft) ?
                                                           @3 : @2]
                                             withDelegate:self];
        
    } else if (direction == SWScrollDirectionUp) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeUpAction" defaultValue:@7]
                                             withDelegate:self];
        
    } else if (direction == SWScrollDirectionDown) {
        
        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
                                                           valueForKey:@"swipeDownAction" defaultValue:@6]
                                             withDelegate:self];
        
    }
    
    if (action){
        action();
    } else {
        if (swAcapella == self.acapella.scrollview){
            [self.acapella.scrollview finishWrapAroundAnimation];
        } else if (swAcapella == self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:YES];
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
                    
                    if ([self progressControl]){
                        [cell addSubview:[self progressControl]];
                    }
                    
                    break;
                    
                case 1:
                    
                    if ([self trackInformationView] && view.scrollview){
                        [view.scrollview addSubview:[self trackInformationView]];
                        [self trackInformationView].frame = [self trackInformationView].frame;
                    }
                    
                    break;
                    
                case 2:
                    
                    if ([self progressControl].superview){
                        [[self progressControl] removeFromSuperview];
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

#pragma mark - Actions

%new
- (void)action_PlayPause
{
    [SWAcapellaActionsHelper action_PlayPause:^(BOOL successful, id object){
        if (successful && [self trackInformationView]){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 [self trackInformationView].transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      [self trackInformationView].transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      [self trackInformationView].transform = CGAffineTransformMakeScale(1.0, 1.0);
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
                
                MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul),
                                               ^(CFDictionaryRef result){
                                                   
                                                   NSDictionary *resultDict = (__bridge NSDictionary *)result;
                                                   
                                                   if (resultDict){
                                                       
                                                       double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
                                                       
                                                       if (mediaCurrentElapsedDuration >= 2.0 || mediaCurrentElapsedDuration <= 0.0){
                                                           
                                                           [self.acapella.scrollview finishWrapAroundAnimation];
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
        
        
        TBAlertController *c = [[TBAlertController alloc] initWithTitle:@"Activity"
                                                                message:nil
                                                                  style:TBAlertControllerStyleActionSheet];
        
        
        [c setCancelButtonWithTitle:@"Cancel" buttonAction:^(NSArray *textFieldStrings){
            [self.acapella.tableview resetContentOffset:YES];
            [self.acapella.scrollview finishWrapAroundAnimation];
        }];
        
        if (object){ //share data
            
            NSDictionary *shareData = (NSDictionary *)object;
            
            //Twitter
            [c addOtherButtonWithTitle:@"Twitter" buttonAction:^(NSArray *textFieldStrings){
                
                if (successful){ //device isnt locked and we have data
                    
                    SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    
                    if ([shareData valueForKey:@"shareString"]){
                        [compose setInitialText:[shareData valueForKey:@"shareString"]];
                    }
                    if ([shareData valueForKey:@"shareImage"]){
                        [compose addImage:[shareData valueForKey:@"shareImage"]];
                    }
                    
                    compose.completionHandler = ^(SLComposeViewControllerResult result) {
                        [self.acapella.tableview resetContentOffset:YES];
                        [self.acapella.scrollview finishWrapAroundAnimation];
                    };
                    
                    [self presentViewController:compose animated:YES completion:nil];
                    
                } else {
                    
                    TBAlertController *fail = [[TBAlertController alloc] initWithTitle:@"Error"
                                                                               message:@"You cannot share from the Lock Screen for security reasons"
                                                                                 style:TBAlertControllerStyleActionSheet];
                    [fail setCancelButtonWithTitle:@"Ok" buttonAction:^(NSArray *textFieldStrings){
                        [self.acapella.tableview resetContentOffset:YES];
                        [self.acapella.scrollview finishWrapAroundAnimation];
                    }];
                    [fail showFromViewController:self];
                    
                }
            }];
            
            //Facebook
            [c addOtherButtonWithTitle:@"Facebook" buttonAction:^(NSArray *textFieldStrings){
                
                if (successful){ //device isnt locked and we have data
                    
                    SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                    
                    if ([shareData valueForKey:@"shareString"]){
                        [compose setInitialText:[shareData valueForKey:@"shareString"]];
                    }
                    if ([shareData valueForKey:@"shareImage"]){
                        [compose addImage:[shareData valueForKey:@"shareImage"]];
                    }
                    
                    compose.completionHandler = ^(SLComposeViewControllerResult result) {
                        [self.acapella.tableview resetContentOffset:YES];
                        [self.acapella.scrollview finishWrapAroundAnimation];
                    };
                    
                    [self presentViewController:compose animated:YES completion:nil];
                    
                } else {
                    
                    TBAlertController *fail = [[TBAlertController alloc] initWithTitle:@"Error"
                                                                               message:@"You cannot share from the Lock Screen for security reasons"
                                                                                 style:TBAlertControllerStyleActionSheet];
                    [fail setCancelButtonWithTitle:@"Ok" buttonAction:^(NSArray *textFieldStrings){
                        [self.acapella.tableview resetContentOffset:YES];
                        [self.acapella.scrollview finishWrapAroundAnimation];
                    }];
                    [fail showFromViewController:self];
                    
                }
            }];
            
        }
        
        
        if (c.numberOfButtons > 1){ //1 means only cancel button
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [c showFromViewController:self];
            });
        } else {
            c = nil;
            
            [self.acapella.tableview resetContentOffset:YES];
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
            
            TBAlertController *c = [[TBAlertController alloc] initWithTitle:@"Playlist Options"
                                                                    message:nil
                                                                      style:TBAlertControllerStyleActionSheet];
            
            
            [c setCancelButtonWithTitle:@"Cancel" buttonAction:^(NSArray *textFieldStrings){
                [self.acapella.tableview resetContentOffset:YES];
                [self.acapella.scrollview finishWrapAroundAnimation];
            }];
            
            
            
            [c addOtherButtonWithTitle:@"Create" buttonAction:^(NSArray *textFieldStrings){
                
                SEL createSelector = NSSelectorFromString(@"_createAction:");
                
                if ([[self mediaControlsView] respondsToSelector:createSelector]){
                    [[self mediaControlsView] performSelectorOnMainThread:createSelector
                                                                  withObject:[self createButton]
                                                               waitUntilDone:NO];
                }
                
                [self.acapella.tableview resetContentOffset:YES];
                [self.acapella.scrollview finishWrapAroundAnimation];
            }];
            
            
            
            for (NSUInteger x = 0; x < 3; x++){
                
                [c addOtherButtonWithTitle:NSStringForRepeatMode(x) buttonAction:^(NSArray *textFieldStrings){
                    MRMediaRemoteSetRepeatMode(x);
                    [self.acapella.tableview resetContentOffset:YES];
                    [self.acapella.scrollview finishWrapAroundAnimation];
                }];
                
            }
            
            
            for (NSUInteger x = 0; x < 3; x++){
                
                if (x != 1){ //1 isnt a valid shuffle mode
                    
                    [c addOtherButtonWithTitle:NSStringForShuffleMode(x) buttonAction:^(NSArray *textFieldStrings){
                        MRMediaRemoteSetShuffleMode(x);
                        [self.acapella.tableview resetContentOffset:YES];
                        [self.acapella.scrollview finishWrapAroundAnimation];
                    }];
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [c showFromViewController:self];
            });
            
        } else {
            [self.acapella.tableview resetContentOffset:YES];
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
    
    if (self.acapella){
        
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





#pragma mark - MPURatingControl

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
    SWAcapellaBase *acapella;
    
    for (UIView *v in mpu.subviews){
        if ([v isKindOfClass:%c(SWAcapellaBase)]){
            acapella = (SWAcapellaBase *)v;
        }
    }
    
    //if acapella is not nil, then we know it is enabled
    if (acapella){
        
        UIView *time = MSHookIvar<UIView *>(mpu, "_progressControl");
        //UIView *titles = MSHookIvar<UIView *>(mpu, "_titlesView");
        UIView *transport = MSHookIvar<UIView *>(mpu, "_transportControls");
        UIView *volume = MSHookIvar<UIView *>(mpu, "_volumeSlider");
        
        transport.center = CGPointMake(6900, transport.center.y);
        
        //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
        if (time && ([time.superview isKindOfClass:[UITableViewCell class]] ||
                     [time.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
            
            time.center = CGPointMake(CGRectGetMidX(time.superview.bounds), CGRectGetMidY(time.superview.bounds));
            
        }
        
        //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
        if (volume && ([volume.superview isKindOfClass:[UITableViewCell class]] ||
                       [volume.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
            
            volume.center = CGPointMake(CGRectGetMidX(volume.superview.bounds), CGRectGetMidY(volume.superview.bounds));
            
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
    %orig();
    
    mpPlaybackControlsPostLayout(self);
    
    //iOS 7 auto layout bug. Need to call or crash
    [self layoutIfNeeded];
}

%end





#pragma mark - logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




