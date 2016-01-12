//
//  MusicMiniPlayerViewController.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapella.h"
#import "SWAcapellaMediaItemPreviewViewController.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/libSluthware/SWPrefs.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"
#import "MusicTabBarController.h"

#define PREF_KEY_PREFIX @"musicmini"
#define PREF_APPLICATION @"com.apple.Music"

#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController")





#pragma mark - MusicMiniPlayerViewController

@interface MusicMiniPlayerViewController : UIViewController <UIViewControllerPreviewingDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

//new
- (SWAcapella *)acapella;

- (UIView *)titlesView;
- (UIView *)playbackProgressView;
- (MPUTransportControlsView *)transportControlsView;
- (MPUTransportControlsView *)secondaryTransportControlsView;

- (UIPanGestureRecognizer *)nowPlayingPresentationPanRecognizer;

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2; //NS_AVAILABLE_IOS(9_0);
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2; //NS_AVAILABLE_IOS(9_0);

@end





%hook MusicMiniPlayerViewController

#pragma mark - Init

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
    //Reload our transport buttons
    //See [self transportControlsView:arg1 buttonForControlType:arg2];
    
    //LEFT SECTION
    [self.transportControlsView reloadTransportButtonWithControlType:1];
    [self.transportControlsView reloadTransportButtonWithControlType:3];
    [self.transportControlsView reloadTransportButtonWithControlType:4];
    
    //RIGHT SECTION
    [self.secondaryTransportControlsView reloadTransportButtonWithControlType:7];
    [self.secondaryTransportControlsView reloadTransportButtonWithControlType:11];
    
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    if (!self.acapella) {
        
        NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"enabled"];
        
        if ([[SWPrefs valueForKey:enabledKey application:PREF_APPLICATION] boolValue]) {
            
            [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                          preInitializeAction:^(SWAcapella *a) {
                                                              a.owner = self;
                                                              a.titles = self.titlesView;
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
    
    if (self.acapella) {
        
        self.acapella.prefKeyPrefix = PREF_KEY_PREFIX;
        self.acapella.prefApplication = PREF_APPLICATION;
        
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:self.acapella.pan];
        
        // Register/Unregister for UIViewControllerPreviewing
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
            (self.traitCollection.forceTouchCapability ==  UIForceTouchCapabilityAvailable)) {
            
            [self registerForPreviewingWithDelegate:self sourceView:self.view];
            
        }
        
    }
    
    [self viewDidLayoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    
    %orig(animated);
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    CGRect titlesFrame = self.titlesView.frame;
    
    //intelligently calcualate titles frame based on visible transport controls
    if ([self.transportControlsView hidden_acapella]) {
        titlesFrame.origin.x = 0.0;
        titlesFrame.size.width = self.secondaryTransportControlsView.frame.origin.x;
    }
    
    if ([self.secondaryTransportControlsView hidden_acapella]) {
        titlesFrame.size.width = CGRectGetWidth(self.titlesView.superview.bounds) - titlesFrame.origin.x;
    }
    
    
    self.titlesView.frame = titlesFrame;
    
    
    //show/hide progress slider
    NSString *progressKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"progressslider"];
    BOOL progressVisible = [[SWPrefs valueForKey:progressKey application:PREF_APPLICATION] boolValue];
    self.playbackProgressView.layer.opacity = progressVisible ? 1.0 : 0.0;
    
}

#pragma mark - Acapella(Helper)

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    //THESE CODES ARE DIFFERENT FROM THE MEDIA COMMANDS
    
    //LEFT SECTION
    //1 rewind (IPAD)
    //3 play/pause
    //4 forward (IPAD)
    
    //RIGHT SECTION
    //7 present up next (IPAD)
    //11 contextual
    
    NSString *prefKeyPrefix = PREF_KEY_PREFIX;
    
    if (prefKeyPrefix != nil) {
        
        //LEFT SECTION
        NSString *key_PrevTrack = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_previoustrack"];
        if (arg2 == 1 && ![[SWPrefs valueForKey:key_PrevTrack application:PREF_APPLICATION] boolValue]) {
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_playpause"];
        if (arg2 == 3 && ![[SWPrefs valueForKey:key_PlayPause application:PREF_APPLICATION] boolValue]) {
            return nil;
        }
        
        NSString *key_NextTrack = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_nexttrack"];
        if (arg2 == 4 && ![[SWPrefs valueForKey:key_NextTrack application:PREF_APPLICATION] boolValue]) {
            return nil;
        }
        
        //RIGHT SECTION
        NSString *key_UpNext = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_presentupnext"];
        if (arg2 == 7 && ![[SWPrefs valueForKey:key_UpNext application:PREF_APPLICATION] boolValue]) {
            return nil;
        }
        
        NSString *key_Contextual = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_contextual"];
        if (arg2 == 11 && ![[SWPrefs valueForKey:key_Contextual application:PREF_APPLICATION] boolValue]) {
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

- (void)_tapRecognized:(id)arg1
{
    if (!self.acapella) {
        %orig(arg1);
    }
}

#pragma mark - Acaplla(Actions)

%new
- (void)action_nil:(id)arg1
{
    //if tap and action is set to nil, perform the original tap action
    if (arg1 && [arg1 isKindOfClass:[UITapGestureRecognizer class]]) {
        [(MusicTabBarController *)self.parentViewController presentNowPlayingViewController];
    }
}

%new
- (void)action_heart:(id)arg1
{
}

%new
- (void)action_upnext:(id)arg1
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:7];
        
    } else {
        
        id nowPlaying = [(MusicTabBarController *)self.parentViewController nowPlayingViewController];
        
        [(MusicTabBarController *)self.parentViewController presentViewController:nowPlaying
                                                                         animated:YES
                                                                       completion:^(BOOL finished) {
                                                                           
                                                                           SEL upNext = NSSelectorFromString(@"action_upnext");
                                                                           if ([nowPlaying respondsToSelector:upNext]) {
                                                                               [nowPlaying performSelector:upNext];
                                                                           }
                                                                           
                                                                       }];
        
    }
}

%new
- (void)action_previoustrack:(id)arg1
{
    [self transportControlsView:self.transportControlsView tapOnControlType:1];
}

%new
- (void)action_nexttrack:(id)arg1
{
    [self transportControlsView:self.transportControlsView tapOnControlType:4];
}

%new
- (void)action_intervalrewind:(id)arg1
{
     [self transportControlsView:self.transportControlsView tapOnControlType:2];
}

%new
- (void)action_intervalforward:(id)arg1
{
    [self transportControlsView:self.transportControlsView tapOnControlType:5];
}

%new
- (void)action_seekrewind:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressBeginOnControlType:1];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
    }
}

%new
- (void)action_seekforward:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressBeginOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
    }
}

%new
- (void)action_playpause:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
    [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    //if the 2 commands are different, then something happened when we told the transportControlView to
    //stop seeking, meaning we were seeking
    if (originalLPCommand == newLPCommand) {
        [self transportControlsView:self.transportControlsView tapOnControlType:3];
    }
    
    [self.acapella pulseAnimateView];
}

%new
- (void)action_share:(id)arg1
{
}

%new
- (void)action_toggleshuffle:(id)arg1
{
}

%new
- (void)action_togglerepeat:(id)arg1
{
}

%new
- (void)action_contextual:(id)arg1
{
    [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:11];
}

%new
- (void)action_openapp:(id)arg1
{
}

%new
- (void)action_showratings:(id)arg1
{
}

%new
- (void)action_decreasevolume:(id)arg1
{
}

%new
- (void)action_increasevolume:(id)arg1
{
}

%new
- (void)action_equalizereverywhere:(id)arg1
{
}

#pragma mark - UIViewControllerPreviewing

%new // peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (self.presentedViewController) {
        return nil;
    }
    
    SWAcapellaMediaItemPreviewViewController *previewViewController = [[SWAcapellaMediaItemPreviewViewController alloc] init];
    [previewViewController configureWithCurrentNowPlayingInfo];
    
    return previewViewController;
}

%new // pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
}

#pragma mark - logos

%group preiOS9 //add these if pre iOS 9 so we dont crash calling them

%new
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2
{
}

%new
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2
{
}

%end

%end






%ctor
{
    %init(_ungrouped);
    
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        %init(preiOS9);
    }
    
}




