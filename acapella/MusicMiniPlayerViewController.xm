
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"





@interface MusicMiniPlayerViewController : UIViewController <UIGestureRecognizerDelegate>
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
    return [SWAcapella acapellaForObject:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    if (!self.acapella){
        
        [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                      preInitializeAction:^(SWAcapella *a){
                                                          a.owner = self;
                                                          a.titles = self.titlesView;
                                                      }]
                      ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
        
    }
    
    if (self.acapella){
        
        [self.view addGestureRecognizer:self.acapella.tap];
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:self.acapella.pan];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    %orig(animated);
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    if (self.acapella){ //stretch title frame across the entire view
        
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.acapella){
        
        if (self.acapella.pan == gestureRecognizer || self.acapella.tap == gestureRecognizer){
            return ![touch.view isKindOfClass:[UISlider class]];
        }
        
    }
    
    return YES;
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.acapella){
        
        if (self.acapella.pan == gestureRecognizer){
            
            CGPoint panVelocity = [self.acapella.pan velocityInView:self.acapella.pan.view];
            return (fabs(panVelocity.x) > fabs(panVelocity.y)); //only accept horizontal pans
            
        }
        
    }
    
    return YES;
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    //if (self.acapella){
        return nil;
    //}
    
   // return %orig(arg1, arg2);
}

%new
- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (self.acapella){
        
        MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
        [t handlePushingMediaRemoteCommand:(t.playing) ? 1 : 0];
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.acapella.referenceView.transform = CGAffineTransformMakeScale(1.1, 1.0);
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  self.acapella.referenceView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              } completion:^(BOOL finished){
                                                  self.acapella.referenceView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }];
                         }];
        
    }
}

- (void)_tapRecognized:(id)arg1
{
    if (!self.acapella){
        %orig(arg1);
    }
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
    
    //Disable frame changes. See MusicNowPlayingTitlesView.xm
    self.acapella.titles.tag = 696969;
    
    if ([direction integerValue] == 0){
        [t handlePushingMediaRemoteCommand:4];
    } else if ([direction integerValue] == 1){
        [t handlePushingMediaRemoteCommand:5];
    }
}

%end





#pragma mark - logos

%ctor
{
}




