
#import <AcapellaKit/AcapellaKit.h>

@interface MPUSystemMediaControlsViewController : UIViewController <SWAcapellaDelegate>
{
    id _mediaControlsView;
    //_MPUSystemMediaControlsView *_mediaControlsView; //iOS 7
    //MPUSystemMediaControlsView *_mediaControlsView; //iOS 8
}

- (void)viewWillAppear:(BOOL)arg1;

//new
- (_MPUSystemMediaControlsView *)mediaControlsViewIOS7;
- (MPUSystemMediaControlsView *)mediaControlsViewIOS8;
- (MPUChronologicalProgressView *)timeInformationView;
- (MPUMediaControlsTitlesView *)trackInformationView;
- (MPUTransportControlsView *)transportControlsView;
- (MPUMediaControlsVolumeView *)volumeView;
- (SWAcapellaBase *)acapella;

@end




