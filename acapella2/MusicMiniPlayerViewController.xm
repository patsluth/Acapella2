
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"





@interface MusicMiniPlayerViewController : UIViewController
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;

- (UIView *)titlesView;
- (UIPanGestureRecognizer *)nowPlayingPresentationPanRecognizer;

@end





%hook MusicMiniPlayerViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForOwner:self];
}

- (void)viewDidLoad
{
    %orig();
    
    [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view preInitializeAction:^(SWAcapella *a){
        a.owner = self;
        a.titles = self.titlesView;
    }] ForOwner:self];
    
    if ([self acapella]){
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:self.acapella.pan];
    }
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    if ([self acapella]){
        
        CGRect targetFrame = CGRectMake(0,
                                        self.titlesView.frame.origin.y,
                                        CGRectGetMaxX(self.view.bounds),
                                        self.titlesView.frame.size.width);
        
        if (!CGRectEqualToRect(targetFrame, self.titlesView.frame)){
            self.titlesView.frame = targetFrame;
        }
        
    }
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint panVelocity = [pan velocityInView:pan.view];
        
        if (pan == self.acapella.pan){ //make sure we can still pull up to the MusicNowPlayingViewController
            return (fabs(panVelocity.x) > fabs(panVelocity.y));
        }
        
    }
    
    return YES;
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    if ([self acapella]){
        return nil;
    }
    
    return %orig(arg1, arg2);
}

- (void)_tapRecognized:(id)arg1
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
        
    } else {
        %orig(arg1);
    }
}

%end





#pragma mark - logos

%ctor
{
}



