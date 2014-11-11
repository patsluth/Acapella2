
#import <AcapellaKit/AcapellaKit.h>

@class _MPUSystemMediaControlsView;
@class MPUSystemMediaControlsView;
@class MPUChronologicalProgressView;
@class MPUMediaControlsTitlesView;
@class MPUTransportControlsView;
@class MPUMediaControlsVolumeView;

//#import "_MPUSystemMediaControlsView.h"
//#import "MPUSystemMediaControlsView.h"
//#import "MPUChronologicalProgressView.h"
//#import "MPUMediaControlsTitlesView.h"
//#import "MPUTransportControlsView.h"
//#import "MPUMediaControlsVolumeView.h"

@interface MPUSystemMediaControlsViewController : UIViewController <SWAcapellaDelegate>
{
    id _mediaControlsView;
    //_MPUSystemMediaControlsView *_mediaControlsView; //iOS 7
    //MPUSystemMediaControlsView *_mediaControlsView; //iOS 8
}

//new. convenience for different ios versions
- (_MPUSystemMediaControlsView *)mediaControlsViewIOS7;
- (MPUSystemMediaControlsView *)mediaControlsViewIOS8;
- (MPUChronologicalProgressView *)timeInformationView;
- (MPUMediaControlsTitlesView *)trackInformationView;
- (MPUTransportControlsView *)transportControlsView;
- (MPUMediaControlsVolumeView *)volumeView;

@end




@interface MPUSystemMediaControlsViewController(SW)
{
}

@property (strong, nonatomic) SWAcapellaBase *acapella;

@end



