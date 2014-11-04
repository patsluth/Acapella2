
#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>

#import "_MPUSystemMediaControlsView.h"
#import "MPUSystemMediaControlsViewController.h"
#import "SBMediaController.h"
#import "UIApplication+JB.h"
#import "AVSystemController.h"

#import "substrate.h"

%hook MPUSystemMediaControlsViewController

- (void)viewDidLoad
{
    %orig();
    
    _MPUSystemMediaControlsView *mpuSystemMediaControlsView =  MSHookIvar<_MPUSystemMediaControlsView *>(self, "_mediaControlsView");
    
    if (mpuSystemMediaControlsView){
        SWAcapellaBase *acapella = [[%c(SWAcapellaBase) alloc] init];
        acapella.delegateAcapella = self;
        [mpuSystemMediaControlsView addSubview:acapella];
    } else {
        [[[SWUIAlertView alloc] initWithTitle:@"Acapella Error #6810"
                                      message:@"There was an error loading Acapella. Contact Developer with error code if you wish to help :)"
                           clickedButtonBlock:nil
                              didDismissBlock:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil] show];
    }
}

%new
- (SWAcapellaBase *)acapella
{
    SWAcapellaBase *acapella;
    
    _MPUSystemMediaControlsView *mpuSystemMediaControlsView =  MSHookIvar<_MPUSystemMediaControlsView *>(self, "_mediaControlsView");
    
    if (mpuSystemMediaControlsView){
        for (SWAcapellaBase *a in mpuSystemMediaControlsView.subviews){
            acapella = a;
        }
    }
    
    return acapella;
}

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapellaOnTap:(CGPoint)percentage
{
    //NSLog(@"Acapella On Tap %@", NSStringFromCGPoint(percentage));
    
    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    
    void (^_changeVolume)(long direction) = ^(long direction){
        
        AVSystemController *avsc = [%c(AVSystemController) sharedAVSystemController];
        
        if (avsc){ //0.0625 = 1 / 16 (number of squares in iOS HUD)
            [[UIApplication sharedApplication] setSystemVolumeHUDEnabled:NO forAudioCategory:AUDIO_VIDEO_CATEGORY];
            [avsc changeVolumeBy:0.0625 * direction forCategory:AUDIO_VIDEO_CATEGORY];
            
            //float newVolume;
            //[avsc getVolume:&newVolume forCategory:AUDIO_VIDEO_CATEGORY];
            
            //NSInteger newVolumeRounded = (NSInteger)(newVolume * 100);
            //TODO SHOW ACTION INDICATOR
        }
        
    };
    
    
    
    
    
    CGFloat percentBoundaries = 0.25;
    
   	if (percentage.x <= percentBoundaries){ //left
        _changeVolume(-1);
   	} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
        if (sbMediaController){
            [sbMediaController togglePlayPause];
        }
        
        SWAcapellaBase *acapella = [self acapella];
        
        if (acapella){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 acapella.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      acapella.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      acapella.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
        }
        
   	} else if (percentage.x > (1.0 - percentBoundaries)){ //right
   	    _changeVolume(1);
   	}
}

%new
- (void)swAcapellaOnSwipe:(SW_SCROLL_DIRECTION)direction
{
    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    
    if (direction == SW_DIRECTION_LEFT || direction == SW_DIRECTION_RIGHT){
        
        [self.acapella stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated
        
        long skipDirection = (direction == SW_DIRECTION_LEFT) ? -1 : 1;
        
        if (sbMediaController){
            [sbMediaController changeTrack:(int)skipDirection];
        }
        
        _MPUSystemMediaControlsView *mpuSystemMediaControlsView =  MSHookIvar<_MPUSystemMediaControlsView *>(self, "_mediaControlsView");
        //notification when our title view text has changed
        if (mpuSystemMediaControlsView){
            __block id textChange = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUMediaControlsTitleViewTextDidChange"
                                                                                      object:nil
                                                                                       queue:[NSOperationQueue mainQueue]
                                                                                  usingBlock:^(NSNotification *note){
                                                                                      MPUMediaControlsTitlesView *title = MSHookIvar<MPUMediaControlsTitlesView *>(mpuSystemMediaControlsView,
                                                                                                                                                                   "_trackInformationView");
                                                                                      if (title && title == note.object){
                                                                                          [self.acapella finishWrapAroundAnimation];
                                                                                      }
                                                                                      
                                                                                      if (textChange){
                                                                                          [[NSNotificationCenter defaultCenter] removeObserver:textChange];
                                                                                      }
                                                                                  }];
        } else {
            [self.acapella finishWrapAroundAnimation];
        }
        
        
    } else {
        [self.acapella finishWrapAroundAnimation];
    }
}

%new
- (void)swAcapellaOnLongPress:(CGPoint)percentage
{
    //NSLog(@"Acapella On Long Press %@", NSStringFromCGPoint(percentage));
    
    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    
    void (^_changeSongPlaybackTime)(double seconds) = ^(double seconds){
        
        if (sbMediaController){
            double newTime = [sbMediaController trackElapsedTime] + seconds;
            //double totalTime = [sbMediaController trackDuration];
            
            [sbMediaController setCurrentTrackTime:newTime];
        }
        
        
        
        
        //TODO ADD ACTION INDICATOR
       	// double progressPercent = newTime / totalTime;
        
        // //TODO CLAMP IN SWMATH
        // if (progressPercent < 0.0){
        //     progressPercent = 0.0;
        // } else if (progressPercent > 1.0){
        //     progressPercent = 1.0;
        // }
        
        // NSInteger progressPercentRounded = (NSInteger)(progressPercent * 100);
        
        // NSString *display = [NSString stringWithFormat:@"%ld%@", (long)progressPercentRounded, @"%"];
        
    };
    
    
    
    
    CGFloat percentBoundaries = 0.25;
    
   	if (percentage.x <= percentBoundaries){ //left
        _changeSongPlaybackTime(-30);
   	} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
   	} else if (percentage.x > (1.0 - percentBoundaries)){ //right
   	    _changeSongPlaybackTime(30);
   	}
}

%end

%hook SBCCMediaControlsSectionController
- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    //CGSize new = CGSizeMake(original.width, original.height - PROGRESS HEIGHT - VOLUME HEIGHT);
    return original;
}

%end

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}