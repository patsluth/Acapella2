
@class MPAVController;
@class MPAVItem;

#import "SWAcapellaActionsHelper.h"

@interface MusicNowPlayingViewController : UIViewController <SWAcapellaDelegate, SWAcapellaActionProtocol>
{
    //MPAVController *_player; //iOS 8 only
                                //we can use the same variable on _playbackControlsView
                                //so we can use the same code on both iOS versions
    MPAVItem *_item; //iOS 7 & 8
}

//@property (retain) MPAVController *player;  //iOS 8 only

- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2; //iOS 7 & 8













//- (id)titlesView;
//
//
//- (void)_pushMediaRemoteCommand...;
//- (void)_setCurrentItem:(id) skipUpdatingView:(BOOL) forceUpdatingView:(BOOL);
//- (void)updateNowPlayingInfo;
//- (void)_updateTitles;



//MusicMiniPlayerViewController ... _titlesView












//PROPERTIES

/*
 
 player,
 adInfoButton,
 currentItemViewController,
 dismissButton,
 playbackProgressSliderView,
 titlesView,
 transportControls,
 volumeSlider,
 secondaryTransportControls,
 persistentAnimationLayers,
 accessoryStyle,
 currentItemViewControllerContainerView,
 currentItemViewControllerBackgroundView,
 presentedDetailViewController,
 backgroundClippingView,
 backgroundView,
 vibrantEffectView,
 detailContainerView,
 ratingControl,
 skipLimitView,
 statusBarLegibilityGradient,
 playbackProgressSliderController,
 transportControlMediaRemoteController,
 secondaryTransportControlMediaRemoteController,
 trackDownloadButton,
 hash,
 superclass,
 description,
 debugDescription,
 clientContext
 
 */

- (id)player;
- (id)currentItemViewController;




- (UIView *)playbackProgressSliderView;
- (UIView *)titlesView;
- (UIView *)transportControls;
- (UIView *)volumeSlider;

//above views superview is the same
/*
 superview is UIView
 
 property ----    @property(x, x) UIView *focuedView;
 
 focuesView contains the media controls
 
    MusicPlaybackProgressSliderView
    MusicNowPlayingTitlesView
    MusicNowPlayingRatingControl
    MPUTransportControlsView --- (heart, prev, play/pause, next, upNext)
    MusicNowPlayingVolumeSlider
    MPUTransportControlsView --- (share, shuffle, repeat, ...)
    MPUSkipLimitView
 
 
 */











@end




