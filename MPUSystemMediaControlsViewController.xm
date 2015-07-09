
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"
#import "UISnapBehaviorHorizontal.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"





@interface MPUSystemMediaControlsView : UIView
{
}

- (UIView *)timeInformationView;
- (UIView *)trackInformationView;
- (UIView *)transportControlsView;
- (UIView *)volumeView;

@end


@interface MPUSystemMediaControlsViewController : UIViewController
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (MPUSystemMediaControlsView *)mediaControlsView;

@end





%hook MPUSystemMediaControlsViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForOwner:self];
}

%new
- (MPUSystemMediaControlsView *)mediaControlsView
{
    return MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");
}

- (void)viewDidLoad
{
    %orig();
    
    [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view preInitializeAction:^(SWAcapella *a){
        a.owner = self;
        a.titles = self.mediaControlsView.trackInformationView;
        a.topSlider = self.mediaControlsView.timeInformationView;
        a.bottomSlider = self.mediaControlsView.volumeView;
    }] ForOwner:self];
    
    if ([self acapella]){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tap.cancelsTouchesInView = YES;
        [self.view addGestureRecognizer:tap];
    }
    
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    //0 Play
    //1 Pause
    //2 Stop
    //3 TogglePlayPause
    //4 Skip Forward
    //5 Skip Backwards
    
    if ([self acapella]){
        if (arg2 >= 0 && arg2 <= 5){
            return nil;
        }
    }
    
    return %orig(arg1, arg2);
}

%new
- (void)onTap:(UITapGestureRecognizer *)tap
{
    if ([self acapella]){
        
        MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
        
        [t handlePushingMediaRemoteCommand:(t.playing) ? 1 : 0];
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              } completion:^(BOOL finished){
                                                  self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }];
                         }];
        
    }
}

%end





#pragma mark - logos

%ctor
{
}




