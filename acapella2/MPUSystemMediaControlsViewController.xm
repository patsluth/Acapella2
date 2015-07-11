
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

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
    
    [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.mediaControlsView preInitializeAction:^(SWAcapella *a){
        a.owner = self;
        a.titles = self.mediaControlsView.trackInformationView;
        a.topSlider = self.mediaControlsView.timeInformationView;
        a.bottomSlider = self.mediaControlsView.volumeView;
    }] ForOwner:self];
    
    if (self.acapella){
        
        for (UIView *v in self.acapella.titles.subviews){
            if ([v isKindOfClass:[UIButton class]]){
                [v removeFromSuperview];
            }
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tap.cancelsTouchesInView = YES;
        [self.mediaControlsView addGestureRecognizer:tap];
        
    }
    
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.acapella && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        if (pan == self.acapella.pan){ //make sure the default music app GR can still pull down vertically
            CGPoint panVelocity = [pan velocityInView:pan.view];
            return (fabs(panVelocity.x) > fabs(panVelocity.y));
        }
        
    }
    
    return YES;
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    //see MPUTransportControlMediaRemoteController.h
    if (self.acapella){
        if (arg2 >= 0 && arg2 <= 5){
            return nil;
        }
    }
    
    return %orig(arg1, arg2);
}

%new
- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (self.acapella){
            
        MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
        
        [t handlePushingMediaRemoteCommand:(t.playing) ? 1 : 0];
        
        self.mediaControlsView.tag = 696969;
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              } completion:^(BOOL finished){
                                                  self.mediaControlsView.tag = 0;
                                                  self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }];
                         }];
        
    }
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
    
    //Disable frame changes. See MusicNowPlayingTitlesView.xm
    self.mediaControlsView.tag = 696969;
    self.acapella.titles.tag = 696969;
    
    if ([direction integerValue] == 0){
        [t handlePushingMediaRemoteCommand:4];
    } else if ([direction integerValue] == 1){
        [t handlePushingMediaRemoteCommand:5];
    }
}

%end





%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    if (self.tag == 696969){
        return;
    }
    
    %orig();
}

%end





@interface MPUChronologicalProgressView : UIView
{
}

@end


%hook MPUChronologicalProgressView

- (void)setFrame:(CGRect)frame
{
    if (self.tag == 696969){
        return;
    }
    
    %orig(frame);
}

%end





@interface MPUMediaControlsVolumeView : UIView
{
}

@end


%hook MPUMediaControlsVolumeView

- (void)setFrame:(CGRect)frame
{
    if (self.tag == 696969){
        return;
    }
    
    %orig(frame);
}

%end





#pragma mark - logos

%ctor
{
}




