

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




#pragma mark MPUSystemMediaControlsViewController

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
SWAcapellaBase *acapella;

UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");

if (mediaControlsView){
for (UIView *v in mediaControlsView.superview.subviews){
if ([v isKindOfClass:%c(SWAcapellaBase)]){
acapella = (SWAcapellaBase *)v;
}
}
}

return acapella;
}

#pragma mark Init

- (void)viewDidLoad
{
%orig();
}

- (void)viewDidLayoutSubviews
{
%orig();

UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");

if ([self acapella]){ //we already set up an acapella
return;
}

//make sure our frames are set up
[mediaControlsView.superview layoutSubviews];
[mediaControlsView layoutSubviews];

if (mediaControlsView){

if ([self timeInformationView] && [self trackInformationView] && [self transportControlsView] && [self volumeView]){ //make sure we have all our views

SWAcapellaBase *(^_createAcapella)(MPUMediaControlsTitlesView *title) = ^(MPUMediaControlsTitlesView *trackView){

SWAcapellaBase *acapella = [[%c(SWAcapellaBase) alloc] init];
acapella.delegateAcapella = self;

trackView.userInteractionEnabled = NO;
trackView.backgroundColor = [UIColor blueColor];
[acapella.scrollview addSubview:trackView];

return acapella;
};

[[self timeInformationView] removeFromSuperview];
[[self transportControlsView] removeFromSuperview];
[[self volumeView] removeFromSuperview];

SWAcapellaBase *acapella = _createAcapella([self trackInformationView]);
acapella.frame = mediaControlsView.frame;
[acapella layoutSubviews];

[mediaControlsView.superview addSubview:acapella];

[acapella.scrollview addSubview:[self trackInformationView]];
mediaControlsView.hidden = YES;
}
}
}

- (void)viewWillAppear:(BOOL)arg1
{
%orig(arg1);
}

- (void)viewDidAppear:(BOOL)arg1
{
%orig(arg1);
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



//show the action view
MPUSystemMediaControlsView *mediaControlsView = MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");

if (mediaControlsView){

SWAcapellaBase *acapella = [self acapella];

if (acapella){

//                    [self.acapella.actionIndicatorController addSubview:mediaControlsView.volumeView];
//                    [mediaControlsView.volumeView setCenterY:self.acapella.actionIndicatorController.frame.size.height / 2];
//                    return;

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
//    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
//
//    if (direction == SW_DIRECTION_LEFT || direction == SW_DIRECTION_RIGHT){
//
//        [self.acapella stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated
//
//        if (sbMediaController && [sbMediaController _nowPlayingInfo]){ //make sure something is playing
//
//            _MPUSystemMediaControlsView *mpuSystemMediaControlsView = MSHookIvar<_MPUSystemMediaControlsView *>(self, "_mediaControlsView");
//            //notification when our title view text has changed
//            if (mpuSystemMediaControlsView){
//                __block id textChange = [[NSNotificationCenter defaultCenter] addObserverForName:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText"
//                                                                                          object:nil
//                                                                                           queue:[NSOperationQueue mainQueue]
//                                                                                      usingBlock:^(NSNotification *note){
//                                                                                          MPUMediaControlsTitlesView *title = MSHookIvar<MPUMediaControlsTitlesView *>(mpuSystemMediaControlsView,
//                                                                                                                                                                       "_trackInformationView");
//                                                                                          if (title && title == note.object){
//                                                                                              [self.acapella finishWrapAroundAnimation];
//                                                                                          }
//
//                                                                                          if (textChange){
//                                                                                              [[NSNotificationCenter defaultCenter] removeObserver:textChange];
//                                                                                          }
//                                                                                      }];
//            } else {
//                [self.acapella finishWrapAroundAnimation];
//            }
//
//            long skipDirection = (direction == SW_DIRECTION_LEFT) ? -1 : 1;
//            [sbMediaController changeTrack:(int)skipDirection];
//
//        } else {
//            [self.acapella finishWrapAroundAnimation];
//        }
//
//
//    } else if (direction == SW_DIRECTION_UP){
//
//
//
//
//    } else {
//        [self.acapella finishWrapAroundAnimation];
//    }
}

%new
- (void)swAcapellaOnLongPress:(CGPoint)percentage
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

//%hook SBCCMediaControlsSectionController
//
//- (CGSize)contentSizeForOrientation:(long long)arg1
//{
//    CGSize original = %orig(arg1);
//
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        //return CGSizeMake(original.width, original.height - 60); //approximate height of progress and volume
//    }
//
//    return original;
//}
//
//%end





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
[self.volumeView setCenterY:self.volumeView.superview.frame.size.height / 2]; //sometimes dissapears while showing in the action indicator
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
[self.volumeView setCenterY:self.volumeView.superview.frame.size.height / 2]; //sometimes dissapears while showing in the action indicator
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