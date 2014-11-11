//
//  SBApplicationController.h
//  SWGestureMusicControls
//
//  Created by Pat Sluth on 2014-07-30.
//
//

@interface SBApplicationController
{
}

+ (id)sharedInstanceIfExists;
+ (id)sharedInstance;
- (id)applicationWithDisplayIdentifier:(id)arg1; //ios 7 & 8 :)
- (id)applicationsWithPid:(int)arg1;
- (id)applicationsWithBundleIdentifier:(id)arg1;
- (id)allApplications;
- (id)allDisplayIdentifiers;
- (id)iPod;

@end




