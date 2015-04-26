
@class SWAcapellaBase;
@class _MPUSystemMediaControlsView;
@class MPUSystemMediaControlsView;
@class MPUChronologicalProgressView;
@class MPUMediaControlsTitlesView;
@class MPUTransportControlsView;
@class MPUMediaControlsVolumeView;

@class MPUNowPlayingController;

#import "SWAcapellaActionsHelper.h"





@interface MPUSystemMediaControlsViewController : UIViewController <SWAcapellaDelegate, SWAcapellaActionProtocol>
{
    //_MPUSystemMediaControlsView *_mediaControlsView; //iOS 7
    //MPUSystemMediaControlsView *_mediaControlsView; //iOS 8
    
    MPUNowPlayingController *_nowPlayingController;
    BOOL _nowPlayingIsRadioStation;
}

- (void)_likeBanButtonTapped:(id)arg1;

@end




