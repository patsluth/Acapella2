
#import "MPUChronologicalProgressView.h"
#import "MPUMediaControlsTitlesView.h"
#import "MPUTransportControlsView.h"
#import "MPUMediaControlsVolumeView.h"

@class SWGMCBaseView;

//lock screen and control center media controls base view
@interface _MPUSystemMediaControlsView : UIView
{
    MPUChronologicalProgressView *_timeInformationView;
    MPUMediaControlsTitlesView *_trackInformationView;
    MPUTransportControlsView *_transportControlsView;
    MPUMediaControlsVolumeView *_volumeView;
}

- (id)initWithStyle:(int)arg1; //changes color of items, not line numbers

//new
- (BOOL)showRadioModal;

@end




