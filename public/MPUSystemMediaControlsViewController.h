
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class SWAcapella;
@class MPUSystemMediaControlsView;
@class MPUNowPlayingController;

#define PREF_KEY_PREFIX [self.class prefKeyPrefixByDrillingUp:self.view]
#define PREF_APPLICATION @"com.patsluth.AcapellaPrefs2"





@interface MPUSystemMediaControlsViewController : UIViewController <UIViewControllerPreviewingDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
    MPUNowPlayingController *_nowPlayingController;
}

//new
- (SWAcapella *)acapella;
+ (NSString *)prefKeyPrefixByDrillingUp:(UIView *)view;

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2;

@end



