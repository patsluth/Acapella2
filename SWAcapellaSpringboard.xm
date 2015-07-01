
#import <Social/Social.h>

#import "libSluthware.h"
#import "SWAcapella.h"
#import <AcapellaKit/AcapellaKit.h>
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"

#import "TBAlertController.h"

#import <Springboard/Springboard.h>
#import <MediaRemote/MediaRemote.h>

#import "MPUSystemMediaControlsViewController.h"
#import "_MPUSystemMediaControlsView.h" //iOS 7
#import "MPUSystemMediaControlsView.h" //iOS 8
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
- (void)scrollViewDidScroll:(SWAcapellaScrollView *)scrollView
{
    if ([self trackInformationView]){
        
        CGFloat alpha = 1.0 - (fabs(scrollView.contentOffset.y - scrollView.defaultContentOffset.y) /
                               CGRectGetMidY(scrollView.frame));
        [self trackInformationView].alpha = alpha;
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)swAcapella onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
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
- (void)swAcapella:(SWAcapellaBase *)swAcapella onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
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
        
        if ([self.view.superview isKindOfClass:NSClassFromString(@"SBEqualizerScrollView")]){
            
            [c addOtherButtonWithTitle:@"Equilizer Everywhere" buttonAction:^(NSArray *textFieldStrings){
                
                UIScrollView *eeScrollView = (UIScrollView *)self.view.superview;
                [eeScrollView setContentOffset:CGPointMake(eeScrollView.frame.size.width, 0.0)];
                [self.acapella.tableview resetContentOffset:YES];
                [self.acapella.scrollview finishWrapAroundAnimation];
                
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
    
    //if acapella is not nil, then we know it is enabled
    if (acapella){
        
        UIView *time = MSHookIvar<UIView *>(mpu, "_timeInformationView");
        UIView *transport = MSHookIvar<UIView *>(mpu, "_transportControlsView");
        UIView *volume = MSHookIvar<UIView *>(mpu, "_volumeView");
        
        
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

%hook _MPUSystemMediaControlsView //iOS 7

- (void)layoutSubviews
{
    %orig();
    mpuPostLayoutSubviews(self);
    
    //iOS 7 auto layout bug. Need to call or crash
    [self layoutIfNeeded];
}

%end

%hook MPUSystemMediaControlsView //iOS 8

- (void)layoutSubviews
{
    %orig();
    mpuPostLayoutSubviews(self);
    
    //iOS 7 auto layout bug. Need to call or crash
    [self layoutIfNeeded];
}

%end





#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
    if ([[SWAcapellaPrefsBridge valueForKey:@"cc_enabled" defaultValue:@YES] boolValue]){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            return CGSizeMake(original.width, original.height * 0.75);
        }
    }
    
    return original;
}

%end





#pragma mark - logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




