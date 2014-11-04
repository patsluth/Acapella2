
#import "_MPUSystemMediaControlsView.h"
#import <AcapellaKit/AcapellaKit.h>

@interface MPUSystemMediaControlsViewController : UIViewController  <SWAcapellaDelegate>
{
    _MPUSystemMediaControlsView *_mediaControlsView;
}

- (void)viewWillAppear:(BOOL)arg1;

//new
- (SWAcapellaBase *)acapella;

@end




