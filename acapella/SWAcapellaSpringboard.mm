

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>

#import "_MPUSystemMediaControlsView.h" //iOS 7
#import "MPUSystemMediaControlsView.h" //iOS 8
#import "MPUSystemMediaControlsViewController.h"
#import "SBCCMediaControlsSectionController.h"
#import "SBMediaController.h"
#import "UIApplication+JB.h"
#import "AVSystemController.h"

#import "substrate.h"
#import <objc/runtime.h>




#pragma mark MPUSystemMediaControlsViewController

static SWAcapellaBase *_acapella;
static NSNotification *_titleTextChangeNotification;

%hook MPUSystemMediaControlsViewController

#pragma mark Helper

%new
- (_MPUSystemMediaControlsView *)mediaControlsViewIOS7
{
    return MSHookIvar<_MPUSystemMediaControlsView *>(self, "_mediaControlsView");;
}

%new
- (MPUSystemMediaControlsView *)mediaControlsViewIOS8
{
    return MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");;
}

%new
- (MPUChronologicalProgressView *)timeInformationView
{
    if ([SWDeviceInfo iOSVersion_First] == 7){
        return [self mediaControlsViewIOS7].timeInformationView;
    } else if ([SWDeviceInfo iOSVersion_First] == 8){
        return [self mediaControlsViewIOS8].timeInformationView;
    }
    
    return nil;
}

%new
- (MPUMediaControlsTitlesView *)trackInformationView
{
    if ([SWDeviceInfo iOSVersion_First] == 7){
        return [self mediaControlsViewIOS7].trackInformationView;
    } else if ([SWDeviceInfo iOSVersion_First] == 8){
        return [self mediaControlsViewIOS8].trackInformationView;
    }
    
    return nil;
}

%new
- (MPUTransportControlsView *)transportControlsView
{
    if ([SWDeviceInfo iOSVersion_First] == 7){
        return [self mediaControlsViewIOS7].transportControlsView;
    } else if ([SWDeviceInfo iOSVersion_First] == 8){
        return [self mediaControlsViewIOS8].transportControlsView;
    }
    
    return nil;
}

%new
- (MPUMediaControlsVolumeView *)volumeView
{
    if ([SWDeviceInfo iOSVersion_First] == 7){
        return [self mediaControlsViewIOS7].volumeView;
    } else if ([SWDeviceInfo iOSVersion_First] == 8){
        return [self mediaControlsViewIOS8].volumeView;
    }
    
    return nil;
}

%new
- (SWAcapellaBase *)acapella
{
    return objc_getAssociatedObject(self, &_acapella);
}

%new
- (void)setAcapella:(SWAcapellaBase *)acapella
{
    objc_setAssociatedObject(self, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Init

- (void)viewDidLayoutSubviews
{
    %orig();
    
    UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");
    
    if (mediaControlsView){
    
        if ([self timeInformationView].superview == mediaControlsView){
            [[self timeInformationView] removeFromSuperview];
        }
        if ([self trackInformationView].superview == mediaControlsView){
            [[self trackInformationView] removeFromSuperview];
        }
        if ([self transportControlsView].superview == mediaControlsView){
            [[self transportControlsView] removeFromSuperview];
        }
        if ([self volumeView].superview == mediaControlsView){
            [[self volumeView] removeFromSuperview];
        }
        
        
        if (!self.acapella){
            self.acapella = [[%c(SWAcapellaBase) alloc] init];
            self.acapella.delegateAcapella = self;
        }
        
        self.acapella.frame = mediaControlsView.frame;
        [mediaControlsView.superview addSubview:self.acapella];
        
        [self trackInformationView].userInteractionEnabled = NO;
        [self trackInformationView].backgroundColor = [UIColor blueColor];
        [self.acapella.scrollview addSubview:[self trackInformationView]];
        
        [mediaControlsView layoutSubviews];
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    //UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");
    
    //if (mediaControlsView){
    ///    [mediaControlsView layoutSubviews];
    //}
        
    [self viewDidLayoutSubviews];
//
//    if (self.acapella){
//        [self.acapella.tableview resetContentOffset:NO];
//        self.acapella.tableview.userInteractionEnabled = YES;
//        [self.acapella.scrollview resetContentOffset:NO];
//        self.acapella.scrollview.userInteractionEnabled = YES;
//    }
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onTitleTextDidChangeNotification:)
//                                                 name:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText"
//                                               object:nil];
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)arg1
{
    %orig(arg1);
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig(arg1);
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText" object:nil];
}

#pragma mark Notification

%new
- (void)onTitleTextDidChangeNotification:(NSNotification *)notification
{
//    if (self.acapella && [self.acapella.scrollview page].x != 1){ //1 is the middle page
//        if ([self trackInformationView] && [self trackInformationView] == notification.object){
//            NSLog(@"WE DID HIT THIS %@", notification.object);
//            [self.acapella.scrollview finishWrapAroundAnimation];
//        }
//    }
}

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(CGPoint)percentage
{
    //NSLog(@"Acapella On Tap %@==%@==%@", NSStringFromCGPoint(percentage), self.acapella, view);
    
//    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
//    
//    void (^_changeVolume)(long direction) = ^(long direction){
//        
//        AVSystemController *avsc = [%c(AVSystemController) sharedAVSystemController];
//        
//        if (avsc){ //0.0625 = 1 / 16 (number of squares in iOS HUD)
//            [[UIApplication sharedApplication] setSystemVolumeHUDEnabled:NO forAudioCategory:AUDIO_VIDEO_CATEGORY];
//            [avsc changeVolumeBy:0.0625 * direction forCategory:AUDIO_VIDEO_CATEGORY];
//            
//            //show the action view
//            MPUSystemMediaControlsView *mediaControlsView = MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");
//            
//            if (mediaControlsView){
//                
//                SWAcapellaBase *acapella = [self acapella];
//                
//                if (acapella){
//                    
//                    //                    [self.acapella.actionIndicatorController addSubview:mediaControlsView.volumeView];
//                    //                    [mediaControlsView.volumeView setCenterY:self.acapella.actionIndicatorController.frame.size.height / 2];
//                    //                    return;
//                    
//                    /*
//                     SWAcapellaActionIndicator *volumeActionIndicator = [self.acapella.actionIndicatorController actionIndicatorWithIdentifierIfExists:@"_volumeView"];
//                     
//                     if (!volumeActionIndicator){
//                     volumeActionIndicator = [[%c(SWAcapellaActionIndicator) alloc] initWithFrame:CGRectMake(0,
//                     0,
//                     self.acapella.actionIndicatorController.frame.size.width,
//                     self.acapella.actionIndicatorController.frame.size.height)
//                     andActionIndicatorIdentifier:@"_volumeView"];
//                     volumeActionIndicator.actionIndicatorAnimationOutTime = 2.0;
//                     volumeActionIndicator.actionIndicatorAnimationInTime = 2.0;
//                     volumeActionIndicator.actionIndicatorDisplayTime = 3.0;
//                     [volumeActionIndicator addSubview:mediaControlsView.volumeView];
//                     }
//                     
//                     
//                     
//                     [self.acapella.actionIndicatorController addActionIndicatorToQueue:volumeActionIndicator];
//                     [mediaControlsView.volumeView setCenterY:volumeActionIndicator.frame.size.height / 2];
//                     
//                     __block MPUMediaControlsVolumeView *volumeBlock = mediaControlsView.volumeView;
//                     __block SWAcapellaActionIndicator *volumeActionIndicatorBlock = volumeActionIndicator;
//                     
//                     //dont hide our volume action indicator while we are dragging it
//                     //notification that we started dragging
//                     __block id volumeDragBegin = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUMediaControlsVolumeView__volumeSliderBeganChanging"
//                     object:nil
//                     queue:[NSOperationQueue mainQueue]
//                     usingBlock:^(NSNotification *note){
//                     
//                     if (volumeBlock && volumeBlock == note.object){
//                     //show indefinately. We will handle hiding in the block below
//                     [volumeActionIndicatorBlock delayBySeconds:INT32_MAX];
//                     NSLog(@"PAT TEST STOPPPPPP");
//                     }
//                     
//                     if (volumeDragBegin){
//                     [[NSNotificationCenter defaultCenter] removeObserver:volumeDragBegin];
//                     }
//                     }];
//                     //notification that we ended draggint
//                     __block id volumeDragEnd = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUMediaControlsVolumeView__volumeSliderStoppedChanging"
//                     object:nil
//                     queue:[NSOperationQueue mainQueue]
//                     usingBlock:^(NSNotification *note){
//                     
//                     //once we end dragging, show for its default time
//                     if (volumeBlock && volumeBlock == note.object){
//                     [volumeActionIndicatorBlock delayBySeconds:volumeActionIndicatorBlock.actionIndicatorDisplayTime];
//                     }
//                     
//                     if (volumeDragEnd){
//                     [[NSNotificationCenter defaultCenter] removeObserver:volumeDragEnd];
//                     }
//                     }];
//                     */
//                }
//            }
//        }
//        
//    };
//    
//    
//    
//    
//    
//    CGFloat percentBoundaries = 0.25;
//    
//   	if (percentage.x <= percentBoundaries){ //left
//        _changeVolume(-1);
//   	} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
//        
//        if (sbMediaController){
//            [sbMediaController togglePlayPause];
//        }
//        
//        
//        if (self.acapella){
//            [UIView animateWithDuration:0.1
//                             animations:^{
//                                 self.acapella.scrollview.transform = CGAffineTransformMakeScale(0.9, 0.9);
//                             } completion:^(BOOL finished){
//                                 [UIView animateWithDuration:0.1
//                                                  animations:^{
//                                                      self.acapella.scrollview.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                                  } completion:^(BOOL finished){
//                                                      self.acapella.scrollview.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                                  }];
//                             }];
//        }
//        
//   	} else if (percentage.x > (1.0 - percentBoundaries)){ //right
//   	    _changeVolume(1);
//   	}
}

%new
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    // NSLog(@"Acapella On Swipe %u", direction);
    
//    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
//    
//    if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
//        
//        //[view finishWrapAroundAnimation];
//        
//        [view stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated
//        
//        if (sbMediaController && [sbMediaController _nowPlayingInfo]){ //make sure something is playing
//            
//            long skipDirection = (direction == SW_SCROLL_DIR_LEFT) ? -1 : 1;
//            [sbMediaController changeTrack:(int)skipDirection];
//            //our notification above will handle the wrap around
//            
//        } else {
//            [view finishWrapAroundAnimation];
//        }
//        
//        
//    } else if (direction == SW_SCROLL_DIR_UP){
//        
//    } else {
//        [view finishWrapAroundAnimation];
//    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(CGPoint)percentage
{
    //NSLog(@"Acapella On Long Press %@", NSStringFromCGPoint(percentage));
    
    //    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    //
    //    void (^_changeSongPlaybackTime)(double seconds) = ^(double seconds){
    //
    //        if (sbMediaController){
    //
    //            //show the action view
    //            _MPUSystemMediaControlsView *mpuSystemMediaControlsView = MSHookIvar<_MPUSystemMediaControlsView *>(self, "_mediaControlsView");
    //
    //            if (mpuSystemMediaControlsView){
    //
    //                MPUChronologicalProgressView *progress = MSHookIvar<MPUChronologicalProgressView *>(mpuSystemMediaControlsView, "_timeInformationView");
    //
    //                SWAcapellaBase *acapella = [self acapella];
    //
    //                if (acapella){
    //
    //                    SWAcapellaActionIndicator *progressActionIndicator = [self.acapella.actionIndicatorController actionIndicatorWithIdentifierIfExists:@"_timeInformationView"];
    //
    //                    if (!progressActionIndicator){
    //                        progressActionIndicator = [[%c(SWAcapellaActionIndicator) alloc] initWithFrame:CGRectMake(0,
    //                                                                                                                  0,
    //                                                                                                                  self.acapella.actionIndicatorController.frame.size.width,
    //                                                                                                                  self.acapella.actionIndicatorController.frame.size.height)
    //                                                                          andActionIndicatorIdentifier:@"_timeInformationView"];
    //                        progressActionIndicator.actionIndicatorDisplayTime = 3.0;
    //                        [progressActionIndicator addSubview:progress];
    //                    }
    //
    //                    [self.acapella.actionIndicatorController addActionIndicatorToQueue:progressActionIndicator];
    //
    //                    if (progressActionIndicator.frame.origin.y >= 0.0){ //progress frame keeps being updated somewhere, its easier to just change our view to make it look right
    //                        [progressActionIndicator setOriginY: -progress.frame.origin.y];
    //                    }
    //
    //                    __block MPUChronologicalProgressView *progressBlock = progress;
    //                    __block SWAcapellaActionIndicator *progressActionIndicatorBlock = progressActionIndicator;
    //
    //                    //dont hide our progress action indicator while we are dragging it
    //                    //notification that we started dragging
    //                    __block id progressDragBegin = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUChronologicalProgressView_detailScrubControllerDidBeginScrubbing"
    //                                                                                                     object:nil
    //                                                                                                      queue:[NSOperationQueue mainQueue]
    //                                                                                                 usingBlock:^(NSNotification *note){
    //
    //                                                                                                     if (progressBlock && progressBlock == note.object){
    //                                                                                                         //show indefinately. We will handle hiding in the block below
    //                                                                                                         [progressActionIndicatorBlock delayBySeconds:INT32_MAX];
    //                                                                                                     }
    //
    //                                                                                                     if (progressDragBegin){
    //                                                                                                         [[NSNotificationCenter defaultCenter] removeObserver:progressDragBegin];
    //                                                                                                     }
    //                                                                                                 }];
    //                    //notification that we ended draggint
    //                    __block id progressDragEnd = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUChronologicalProgressView_detailScrubControllerDidEndScrubbing"
    //                                                                                                   object:nil
    //                                                                                                    queue:[NSOperationQueue mainQueue]
    //                                                                                               usingBlock:^(NSNotification *note){
    //
    //                                                                                                   //once we end dragging, show for its default time
    //                                                                                                   if (progressBlock && progressBlock == note.object){
    //                                                                                                       [progressActionIndicatorBlock delayBySeconds:progressActionIndicatorBlock.actionIndicatorDisplayTime];
    //                                                                                                   }
    //
    //                                                                                                   if (progressDragEnd){
    //                                                                                                       [[NSNotificationCenter defaultCenter] removeObserver:progressDragEnd];
    //                                                                                                   }
    //                                                                                               }];
    //                }
    //            }
    //
    //
    //            //change the track time after we show the action indicator, so its already updated
    //            double newTime = [sbMediaController trackElapsedTime] + seconds;
    //            [sbMediaController setCurrentTrackTime:newTime];
    //
    //        }
    //    };
    //
    //
    //
    //
    //    CGFloat percentBoundaries = 0.25;
    //
    //   	if (percentage.x <= percentBoundaries){ //left
    //        _changeSongPlaybackTime(-30);
    //   	} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
    //
    //   	} else if (percentage.x > (1.0 - percentBoundaries)){ //right
    //   	    _changeSongPlaybackTime(30);
    //   	}
}

%end




#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return CGSizeMake(original.width, 130);
    }
    
    return original;
}

%end





#pragma mark MPUSystemMediaControlsView_iOS7
%hook _MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    
    if (self.trackInformationView){
        
        UIScrollView *acapellaScrollview;
        
        if ([self.trackInformationView.superview isKindOfClass:[UIScrollView class]]){
            acapellaScrollview = (UIScrollView *)self.trackInformationView.superview;
        }
        
        if (acapellaScrollview){
            self.trackInformationView.center = CGPointMake(acapellaScrollview.contentSize.width / 2, acapellaScrollview.contentSize.height / 2);
        }
    }
//
//    if (self.volumeView){
//        [self.volumeView setCenterY:self.volumeView.superview.frame.size.height / 2]; //sometimes dissapears while showing in the action indicator
//    }
}

%end
#pragma mark MPUSystemMediaControlsView_iOS8
%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();

    if (self.trackInformationView){
        
        UIScrollView *acapellaScrollview;
        
        if ([self.trackInformationView.superview isKindOfClass:[UIScrollView class]]){
            acapellaScrollview = (UIScrollView *)self.trackInformationView.superview;
        }
        
        if (acapellaScrollview){
            self.trackInformationView.center = CGPointMake(acapellaScrollview.contentSize.width / 2, acapellaScrollview.contentSize.height / 2);
        }
    }
//
//    if (self.volumeView){
//        [self.volumeView setCenterY:self.volumeView.superview.frame.size.height / 2]; //sometimes dissapears while showing in the action indicator
//    }
}

%end




#pragma mark MPUChronologicalProgressView

%hook MPUChronologicalProgressView

- (void)detailScrubControllerDidEndScrubbing:(id)arg1
{
    %orig(arg1);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWAcapella_MPUChronologicalProgressView_detailScrubControllerDidEndScrubbing" object:self];
}

- (void)detailScrubControllerDidBeginScrubbing:(id)arg1
{
    %orig(arg1);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWAcapella_MPUChronologicalProgressView_detailScrubControllerDidBeginScrubbing" object:self];
}

%end




#pragma mark MPUMediaControlsVolumeView

%hook MPUMediaControlsVolumeView

- (void)_volumeSliderBeganChanging:(id)arg1
{
    %orig(arg1);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWAcapella_MPUMediaControlsVolumeView__volumeSliderBeganChanging" object:self];
}

- (void)_volumeSliderStoppedChanging:(id)arg1
{
    %orig(arg1);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWAcapella_MPUMediaControlsVolumeView__volumeSliderStoppedChanging" object:self];
}

%end




#pragma mark logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}