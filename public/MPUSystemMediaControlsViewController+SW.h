
#import "MPUSystemMediaControlsViewController.h"

@class SWAcapella;

#define PREF_KEY_PREFIX [self.class acapella_prefKeyPrefixByDrillingUp:self.view]
#define PREF_APPLICATION @"com.patsluth.AcapellaPrefs2"





@interface MPUSystemMediaControlsViewController(SW) <UIViewControllerPreviewingDelegate>
{
}

- (SWAcapella *)acapella;
+ (NSString *)acapella_prefKeyPrefixByDrillingUp:(UIView *)view;

@end




