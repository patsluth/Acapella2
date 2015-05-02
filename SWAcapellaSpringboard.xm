
#import <Social/Social.h>

#import <AcapellaKit/AcapellaKit.h>
#import "libSluthware.h"
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"
#import "SWAcapella.h"

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
- (UIView *)timeInformationView;
- (UIView *)trackInformationView;
- (UIView *)transportControlsView;
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
    SWAcapellaBase *a = objc_getAssociatedObject(self, &_acapella);
    
    if (!a){
        
        UIView *mediaControlsView = [self mediaControlsView];
        
        if (mediaControlsView) {
            
            //make sure views are all setup for constraints
            if (!([self timeInformationView] &&
                  [self volumeView])){
                return nil;
            }
            
            [self setAcapella:[[%c(SWAcapellaBase) alloc] init]];
            a = objc_getAssociatedObject(self, &_acapella);
            a.delegate = self;
            
            [mediaControlsView addSubview:a];
            [[self timeInformationView].superview bringSubviewToFront:[self timeInformationView]];
            [[self volumeView].superview bringSubviewToFront:[self volumeView]];
            
            //acapella constraints
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:mediaControlsView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:0.0]];
            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
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
    if (self.acapella) {}
    
    %orig();
    
    if (self.acapella){
        
        UIView *mediaControlsView = [self mediaControlsView];
        
        if (mediaControlsView){
            
            [mediaControlsView.superview layoutIfNeeded];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
                                                  object:nil];
    
    MRMediaRemoteUnregisterForNowPlayingNotifications();
}

#pragma mark - MediaRemote

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
        
        CGFloat alpha = 1.0 - (fabs(scrollView.contentOffset.y - scrollView.defaultContentOffset.y) / CGRectGetMidY(scrollView.frame));
        
        [self trackInformationView].alpha = alpha;
        [self trackInformationView].center = CGPointMake((scrollView.contentSize.width / 2) - scrollView.contentOffset.x,
                                                         (scrollView.contentSize.height / 2) - scrollView.contentOffset.y);
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
    
    if (action){
        action();
    } else {
        [swAcapella finishWrapAroundAnimation];
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

#pragma mark - Actions

%new
- (void)action_PlayPause
{
    [SWAcapellaActionsHelper action_PlayPause:^(BOOL successful, id object){
        if (successful){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 self.acapella.superview.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      self.acapella.superview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      self.acapella.superview.transform = CGAffineTransformMakeScale(1.0, 1.0);
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
                
                UIAlertView *c = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"This feature is only available on iOS 8.0 or greater."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
                [c show];
                
                [self.acapella.scrollview finishWrapAroundAnimation];
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
                
                UIAlertView *c = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"This feature is only available on iOS 8.0 or greater."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
                [c show];
                
                [self.acapella.scrollview finishWrapAroundAnimation];
            }
            
        } else { //device is locked
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
    UIView *transport = MSHookIvar<UIView *>(mpu, "_transportControlsView");
    [transport removeFromSuperview];
    
    UIView *volume = MSHookIvar<UIView *>(mpu, "_volumeView");
    //lock to bottom
    volume.center = CGPointMake(CGRectGetMidX(volume.superview.bounds),
                                CGRectGetMaxY(volume.superview.bounds) - CGRectGetMaxY(volume.bounds));
    
    //this will update the text center
    for (UIView *v in mpu.subviews){
        if ([v isKindOfClass:%c(SWAcapellaBase)]){
            SWAcapellaBase *acapella = (SWAcapellaBase *)v;
            [acapella scrollViewDidScroll:acapella.scrollview];
        }
    }
}

%hook _MPUSystemMediaControlsView //iOS 7

- (void)layoutSubviews
{
    //wierd crash with iOS 7, have to call twice :O
    %orig();
    mpuPostLayoutSubviews(self);
    %orig();
    mpuPostLayoutSubviews(self);
}

%end

%hook MPUSystemMediaControlsView //iOS 8

- (void)layoutSubviews
{
    %orig();
    
    mpuPostLayoutSubviews(self);
}

%end





#pragma mark - logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




