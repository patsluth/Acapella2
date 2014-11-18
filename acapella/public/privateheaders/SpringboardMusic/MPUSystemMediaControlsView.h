
#import "MPUChronologicalProgressView.h"
#import "MPUMediaControlsTitlesView.h"
#import "MPUTransportControlsView.h"
#import "MPUMediaControlsVolumeView.h"

@class SWGMCBaseView;

//lock screen and control center media controls base view
@interface MPUSystemMediaControlsView : UIView
{
    MPUChronologicalProgressView *_timeInformationView;
    MPUMediaControlsTitlesView *_trackInformationView;
    MPUTransportControlsView *_transportControlsView;
    MPUMediaControlsVolumeView *_volumeView;
}

@property(readonly, nonatomic) MPUChronologicalProgressView *timeInformationView; // @synthesize timeInformationView=_timeInformationView;
@property(readonly, nonatomic) MPUMediaControlsTitlesView *trackInformationView; // @synthesize trackInformationView=_trackInformationView;
@property(readonly, nonatomic) MPUTransportControlsView *transportControlsView; // @synthesize transportControlsView=_transportControlsView;
@property(readonly, nonatomic) MPUMediaControlsVolumeView *volumeView; // @synthesize volumeView=_volumeView;

- (id)initWithStyle:(int)arg1; //changes color of items, not line numbers

//new
//- (BOOL)showRadioModal;

@end




