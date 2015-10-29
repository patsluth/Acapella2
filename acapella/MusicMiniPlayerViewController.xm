
#import "SWAcapella.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/libSluthware/SWPrefs.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"
#import "MusicTabBarController.h"

#define PREF_KEY_PREFIX @"musicmini"
#define PREF_APPLICATION @"com.apple.Music"

#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController")





@interface MusicMiniPlayerViewController : UIViewController
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
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2;

@end





%hook MusicMiniPlayerViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

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
    
    if (!self.acapella){
        
        NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"enabled"];
        
        if ([[SWPrefs valueForKey:enabledKey application:PREF_APPLICATION] boolValue]){
            
            [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                          preInitializeAction:^(SWAcapella *a){
                                                              a.owner = self;
                                                              a.titles = self.titlesView;
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
    
    if (self.acapella){
        
        self.acapella.prefKeyPrefix = PREF_KEY_PREFIX;
        self.acapella.prefApplication = PREF_APPLICATION;
        
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:(id)self.acapella.pan];
        
    }
    
    [self viewDidLayoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.acapella){ //stop seeking
        
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
        
    }
    
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    
    %orig(animated);
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    CGRect titlesFrame = self.titlesView.frame;
    
    //intelligently calcualate titles frame based on visible transport controls
    if ([self.transportControlsView hidden_acapella]){
        titlesFrame.origin.x = 0.0;
        titlesFrame.size.width = self.secondaryTransportControlsView.frame.origin.x;
    }
    
    if ([self.secondaryTransportControlsView hidden_acapella]){
        titlesFrame.size.width = CGRectGetWidth(self.titlesView.superview.bounds) - titlesFrame.origin.x;
    }
    
    
    self.titlesView.frame = titlesFrame;
    
    
    //show/hide progress slider
    NSString *progressKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"progressslider"];
    BOOL progressVisible = [[SWPrefs valueForKey:progressKey application:PREF_APPLICATION] boolValue];
    self.playbackProgressView.layer.opacity = progressVisible ? 1.0 : 0.0;
    
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
    
    if (prefKeyPrefix != nil){
        
        //LEFT SECTION
        NSString *key_PrevTrack = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_previoustrack"];
        if (arg2 == 1 && ![[SWPrefs valueForKey:key_PrevTrack application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_playpause"];
        if (arg2 == 3 && ![[SWPrefs valueForKey:key_PlayPause application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_NextTrack = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_nexttrack"];
        if (arg2 == 4 && ![[SWPrefs valueForKey:key_NextTrack application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        //RIGHT SECTION
        NSString *key_UpNext = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_presentupnext"];
        if (arg2 == 7 && ![[SWPrefs valueForKey:key_UpNext application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_Contextual = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_contextual"];
        if (arg2 == 11 && ![[SWPrefs valueForKey:key_Contextual application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

- (void)_tapRecognized:(id)arg1
{
    if (!self.acapella){
        %orig(arg1);
    }
}

//%new
//- (void)onTap:(UITapGestureRecognizer *)tap
//{
//    //perform the original tap action if our action is nil
//    if (!sel || (sel && [NSStringFromSelector(sel) isEqualToString:@"action_nil"])){
//        [(MusicTabBarController *)self.parentViewController presentNowPlayingViewController];
//    }
//}

#pragma mark - Actions

%new
- (void)action_none
{
}

%new
- (void)action_heart
{
}

%new
- (void)action_upnext
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:7];
        
    } else {
        
        id nowPlaying = [(MusicTabBarController *)self.parentViewController nowPlayingViewController];
        
        [(MusicTabBarController *)self.parentViewController presentViewController:nowPlaying
                                                                         animated:YES
                                                                       completion:^(BOOL finished){
                                                                           
                                                                           SEL upNext = NSSelectorFromString(@"action_upnext");
                                                                           if ([nowPlaying respondsToSelector:upNext]){
                                                                               [nowPlaying performSelector:upNext];
                                                                           }
                                                                           
                                                                       }];
        
    }
}

%new
- (void)action_previoustrack
{
    [self transportControlsView:self.transportControlsView tapOnControlType:1];
}

%new
- (void)action_nexttrack
{
    [self transportControlsView:self.transportControlsView tapOnControlType:4];
}

%new
- (void)action_intervalrewind
{
     [self transportControlsView:self.transportControlsView tapOnControlType:2];
}

%new
- (void)action_intervalforward
{
    [self transportControlsView:self.transportControlsView tapOnControlType:5];
}

%new
- (void)action_seekrewind
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressBeginOnControlType:1];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand){ //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
    }
}

%new
- (void)action_seekforward
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressBeginOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand){ //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
    }
}

%new
- (void)action_playpause
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
    [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    //if the 2 commands are different, then something happened when we told the transportControlView to
    //stop seeking, meaning we were seeking
    if (originalLPCommand == newLPCommand){
        [self transportControlsView:self.transportControlsView tapOnControlType:3];
    }
    
    [self.acapella pulseAnimateView];
}

%new
- (void)action_share
{
}

%new
- (void)action_toggleshuffle
{
}

%new
- (void)action_togglerepeat
{
}

%new
- (void)action_contextual
{
    [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:11];
}

%new
- (void)action_openapp
{
}

%new
- (void)action_showratings
{
}

%new
- (void)action_decreasevolume
{
}

%new
- (void)action_increasevolume
{
}

%new
- (void)action_equalizereverywhere
{
}

%end




