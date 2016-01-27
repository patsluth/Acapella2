//
//  SWAcapellaBasePSListController.mm
//  AcapellaPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "SWAcapellaBasePSListController.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/libSluthware/SWPrefs.h"




@interface SWAcapellaBasePSListController()
{
}

@end





@implementation SWAcapellaBasePSListController

/**
 *  Lazy Load prefs
 *
 *  @return prefs
 */
- (SWPrefs *)prefs
{
	if (![super prefs]) {
		
		NSString *preferencePath = @"/var/mobile/Library/Preferences/com.patsluth.acapella2.plist";
		NSString *defaultsPath = [self.bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
		
		self.prefs = [[SWPrefs alloc] initWithPreferenceFilePath:preferencePath
													defaultsPath:defaultsPath
													 application:@"com.patsluth.acapella2"];
	}
	
	return [super prefs];
}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *original = [super loadSpecifiersFromPlistName:plistName target:target];
    NSString *key = [self.specifier.properties valueForKey:@"key"];
    NSString *defaults = [self.specifier.properties valueForKey:@"defaults"];
    
    
	// Concatonate keys and set defaults as we get deeper into our view controller stack
    for (PSSpecifier *specifier in original) {
		
		if (key != nil) {
			
			NSString *specifierKey = [specifier.properties valueForKey:@"key"];
			
			if (specifierKey != nil) {
				specifierKey = [NSString stringWithFormat:@"%@_%@", key, specifierKey];
				[specifier.properties setValue:specifierKey forKey:@"key"];
			}
			
			if (defaults) {
				[specifier.properties setValue:defaults forKey:@"defaults"];
			}
			
		}
		
    }
	
    return original;
}

@end




