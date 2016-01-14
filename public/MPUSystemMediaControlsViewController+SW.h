
#import "MPUSystemMediaControlsViewController.h"

#import "SWAcapellaDelegate.h"

#define PREF_KEY_PREFIX [self.class acapella_prefKeyPrefixByDrillingUp:self.view]
#define PREF_APPLICATION @"com.patsluth.AcapellaPrefs2"





@interface MPUSystemMediaControlsViewController(SW) <SWAcapellaDelegate, UIViewControllerPreviewingDelegate>
{
}

+ (NSString *)acapella_prefKeyPrefixByDrillingUp:(UIView *)view;

@end




