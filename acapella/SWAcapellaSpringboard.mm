

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import <libsw/SWAppLauncher.h>

#import "_MPUSystemMediaControlsView.h" //iOS 7
#import "MPUSystemMediaControlsView.h" //iOS 8
#import "MPUSystemMediaControlsViewController.h"
#import "MPUNowPlayingController.h"
#import "SBCCMediaControlsSectionController.h"
#import "SBMediaController.h"
#import "UIApplication+JB.h"
#import "AVSystemController.h"
#import "SBApplicationController.h"

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

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTitleTextDidChangeNotification:)
                                                 name:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText"
                                               object:nil];
}

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
        
        if (self.acapella){
            [self.acapella.tableview resetContentOffset:NO];
            [self.acapella.scrollview resetContentOffset:NO];
        }
        
        [self trackInformationView].userInteractionEnabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
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
    if (self.acapella && [self.acapella.scrollview page].x != 1){ //1 is the middle page
        if ([self trackInformationView] && [self trackInformationView] == notification.object){
            [self.acapella.scrollview finishWrapAroundAnimation];
        }
    }
}

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(CGPoint)percentage
{
    //NSLog(@"Acapella On Tap %@==%@==%@", NSStringFromCGPoint(percentage), self.acapella, view);
    
    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    
    void (^_changeVolume)(long direction) = ^(long direction){
        
        AVSystemController *avsc = [%c(AVSystemController) sharedAVSystemController];
        
        if (avsc){ //0.0625 = 1 / 16 (number of squares in iOS HUD)
            [[UIApplication sharedApplication] setSystemVolumeHUDEnabled:NO forAudioCategory:AUDIO_VIDEO_CATEGORY];
            [avsc changeVolumeBy:0.0625 * direction forCategory:AUDIO_VIDEO_CATEGORY];
            
            //show the action view
            MPUSystemMediaControlsView *mediaControlsView = MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");
            
            if (mediaControlsView){
                
                SWAcapellaBase *acapella = [self acapella];
                
                if (acapella){
                    
                    //                    [self.acapella.actionIndicatorController addSubview:mediaControlsView.volumeView];
                    //                    [mediaControlsView.volumeView setCenterY:self.acapella.actionIndicatorController.frame.size.height / 2];
                    //                    return;
                    
                    /*
                     SWAcapellaActionIndicator *volumeActionIndicator = [self.acapella.actionIndicatorController actionIndicatorWithIdentifierIfExists:@"_volumeView"];
                     
                     if (!volumeActionIndicator){
                     volumeActionIndicator = [[%c(SWAcapellaActionIndicator) alloc] initWithFrame:CGRectMake(0,
                     0,
                     self.acapella.actionIndicatorController.frame.size.width,
                     self.acapella.actionIndicatorController.frame.size.height)
                     andActionIndicatorIdentifier:@"_volumeView"];
                     volumeActionIndicator.actionIndicatorAnimationOutTime = 2.0;
                     volumeActionIndicator.actionIndicatorAnimationInTime = 2.0;
                     volumeActionIndicator.actionIndicatorDisplayTime = 3.0;
                     [volumeActionIndicator addSubview:mediaControlsView.volumeView];
                     }
                     
                     
                     
                     [self.acapella.actionIndicatorController addActionIndicatorToQueue:volumeActionIndicator];
                     [mediaControlsView.volumeView setCenterY:volumeActionIndicator.frame.size.height / 2];
                     
                     __block MPUMediaControlsVolumeView *volumeBlock = mediaControlsView.volumeView;
                     __block SWAcapellaActionIndicator *volumeActionIndicatorBlock = volumeActionIndicator;
                     
                     //dont hide our volume action indicator while we are dragging it
                     //notification that we started dragging
                     __block id volumeDragBegin = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUMediaControlsVolumeView__volumeSliderBeganChanging"
                     object:nil
                     queue:[NSOperationQueue mainQueue]
                     usingBlock:^(NSNotification *note){
                     
                     if (volumeBlock && volumeBlock == note.object){
                     //show indefinately. We will handle hiding in the block below
                     [volumeActionIndicatorBlock delayBySeconds:INT32_MAX];
                     NSLog(@"PAT TEST STOPPPPPP");
                     }
                     
                     if (volumeDragBegin){
                     [[NSNotificationCenter defaultCenter] removeObserver:volumeDragBegin];
                     }
                     }];
                     //notification that we ended draggint
                     __block id volumeDragEnd = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUMediaControlsVolumeView__volumeSliderStoppedChanging"
                     object:nil
                     queue:[NSOperationQueue mainQueue]
                     usingBlock:^(NSNotification *note){
                     
                     //once we end dragging, show for its default time
                     if (volumeBlock && volumeBlock == note.object){
                     [volumeActionIndicatorBlock delayBySeconds:volumeActionIndicatorBlock.actionIndicatorDisplayTime];
                     }
                     
                     if (volumeDragEnd){
                     [[NSNotificationCenter defaultCenter] removeObserver:volumeDragEnd];
                     }
                     }];
                     */
                }
            }
        }
        
    };
    
    
    
    
    
    CGFloat percentBoundaries = 0.25;
    
   	if (percentage.x <= percentBoundaries){ //left
        _changeVolume(-1);
   	} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
        if (sbMediaController){
            [sbMediaController togglePlayPause];
        }
        
        
        if (self.acapella){
            [UIView animateWithDuration:0.1
                             animations:^{
                                 self.acapella.scrollview.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      self.acapella.scrollview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      self.acapella.scrollview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
        }
        
   	} else if (percentage.x > (1.0 - percentBoundaries)){ //right
   	    _changeVolume(1);
   	}
}

%new
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    //NSLog(@"Acapella On Swipe %u", direction);
    
    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    
    if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
        
        [view stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated
        
        if (sbMediaController && [sbMediaController _nowPlayingInfo]){ //make sure something is playing
            
            long skipDirection = (direction == SW_SCROLL_DIR_LEFT) ? -1 : 1;
            [sbMediaController changeTrack:(int)skipDirection];
            //our notification above will handle the wrap around
            
        } else {
            [view finishWrapAroundAnimation];
        }
        
    } else if (direction == SW_SCROLL_DIR_UP){
        
    } else {
        [view finishWrapAroundAnimation];
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(CGPoint)percentage
{
    //NSLog(@"Acapella On Long Press %@", NSStringFromCGPoint(percentage));
    
    void (^_openNowPlayingApp)() = ^(){
        
        MPUNowPlayingController *nowPlayingController = MSHookIvar<MPUNowPlayingController *>(self, "_nowPlayingController");
        
        if (nowPlayingController){
            
            //NSLog(@"%@", nowPlayingController.nowPlayingAppDisplayID);
            
            SBApplicationController *sbAppController = [%c(SBApplicationController) sharedInstanceIfExists];
            
            if (sbAppController){
                SBApplication *nowPlayingApp = [sbAppController applicationWithDisplayIdentifier:nowPlayingController.nowPlayingAppDisplayID];
                [%c(SWAppLauncher) launchAppLockscreenFriendly:nowPlayingApp];
            }
            
        }
        
    };
    
    
    
    
    
    CGFloat percentBoundaries = 0.25;
    
    if (percentage.x <= percentBoundaries){ //left
        _openNowPlayingApp();
    } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        _openNowPlayingApp();
    } else if (percentage.x > (1.0 - percentBoundaries)){ //right
        _openNowPlayingApp();
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Acapella Will Display Cell At Row %ld", (long)indexPath.row);
    
    UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");
    
    if (mediaControlsView){
        
        if (indexPath.section == 0){
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                case 1:
                    
                    if ([self volumeView]){
                        [[self volumeView] removeFromSuperview];
                    }
                    
                    if ([self timeInformationView]){
                        [cell addSubview:[self timeInformationView]];
                    }
                    
                    break;
                    
                case 2:
                    
                    if ([self trackInformationView]){
                        [view.scrollview addSubview:[self trackInformationView]];
                    }
                    
                    break;
                    
                case 3:
                    
                    if ([self timeInformationView]){
                        [[self timeInformationView] removeFromSuperview];
                    }
                    
                    if ([self volumeView]){
                        [cell addSubview:[self volumeView]];
                    }
                    
                    break;
                    
                case 4:
                    
                    break;
                    
                default:
                    break;
            }
        }
        
        [mediaControlsView layoutSubviews];
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0){
//        
//        if (indexPath.row == 1){
//            if ([self timeInformationView] && [self timeInformationView].superview == cell){
//                [[self timeInformationView] removeFromSuperview];
//            }
//        } else if (indexPath.row == 3){
//            if ([self volumeView] && [self volumeView].superview == cell){
//                [[self volumeView] removeFromSuperview];
//            }
//        }
//    }
}

%end




#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return CGSizeMake(original.width, original.height * 0.80);
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
    
    if (self.volumeView){
        
        UIView *acapellaCell;
        
        if ([self.volumeView.superview isKindOfClass:[UIView class]]){
            acapellaCell = (UIView *)self.volumeView.superview;
        }
        
        if (acapellaCell){
            self.volumeView.center = CGPointMake(acapellaCell.frame.size.width / 2, acapellaCell.frame.size.height / 2);
        }
    }
    
    if (self.timeInformationView){
        
        UIView *acapellaCell;
        
        if ([self.timeInformationView.superview isKindOfClass:[UIView class]]){
            acapellaCell = (UIView *)self.timeInformationView.superview;
        }
        
        if (acapellaCell){
            self.timeInformationView.center = CGPointMake(acapellaCell.frame.size.width / 2, acapellaCell.frame.size.height / 2);
        }
    }
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
    
    if (self.volumeView){
        
        UIView *acapellaCell;
        
        if ([self.volumeView.superview isKindOfClass:[UIView class]]){
            acapellaCell = (UIView *)self.volumeView.superview;
        }
        
        if (acapellaCell){
            self.volumeView.center = CGPointMake(acapellaCell.frame.size.width / 2, acapellaCell.frame.size.height / 2);
        }
    }
    
    if (self.timeInformationView){
        
        UIView *acapellaCell;
        
        if ([self.timeInformationView.superview isKindOfClass:[UIView class]]){
            acapellaCell = (UIView *)self.timeInformationView.superview;
        }
        
        if (acapellaCell){
            self.timeInformationView.center = CGPointMake(acapellaCell.frame.size.width / 2, acapellaCell.frame.size.height / 2);
        }
    }
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