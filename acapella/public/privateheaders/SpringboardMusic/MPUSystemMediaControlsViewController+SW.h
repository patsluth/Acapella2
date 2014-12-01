
@class SWAcapellaBase;
@class _MPUSystemMediaControlsView;
@class MPUSystemMediaControlsView;
@class MPUChronologicalProgressView;
@class MPUMediaControlsTitlesView;
@class MPUTransportControlsView;
@class MPUMediaControlsVolumeView;

@class MPUNowPlayingController;

@interface MPUSystemMediaControlsViewController : UIViewController <SWAcapellaDelegate>
{
    //_MPUSystemMediaControlsView *_mediaControlsView; //iOS 7
    //MPUSystemMediaControlsView *_mediaControlsView; //iOS 8
    
    MPUNowPlayingController *_nowPlayingController;
    BOOL _nowPlayingIsRadioStation;
}

- (void)_likeBanButtonTapped:(id)arg1;

@end




@interface MPUSystemMediaControlsViewController(SW)
{
}

@property (strong, nonatomic) SWAcapellaBase *acapella;

- (UIView *)mediaControlsView;
- (UIView *)timeInformationView;
- (UIView *)trackInformationView;
- (UIView *)transportControlsView;
- (UIView *)volumeView;
- (UIView *)buyTrackButton;
- (UIView *)buyAlbumButton;

- (BOOL)nowPlayingTrackIsRadioTrack;

@end



