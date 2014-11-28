#import <Preferences/Preferences.h>

@interface AcapellaPrefsListController: PSListController {
}
@end

@implementation AcapellaPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"AcapellaPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
