//
//  SWAPSListController.mm
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAPSListController.h"

#import <Preferences/Preferences.h>

#import "libsw/libSluthware/libSluthware.h"




@interface SWAPSListController()
{
}

@end





@implementation SWAPSListController

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *original = [super loadSpecifiersFromPlistName:plistName target:target];
    NSString *key = [self.specifier.properties valueForKey:@"key"];
    NSString *defaults = [self.specifier.properties valueForKey:@"defaults"];
    
    
    
    for (PSSpecifier *specifier in original){ //concatenate keys and defaults
        
        NSString *specifierKey = [specifier.properties valueForKey:@"key"];
        
        if (specifierKey != nil){
            specifierKey = [NSString stringWithFormat:@"%@_%@", key, specifierKey];
            [specifier.properties setValue:specifierKey forKey:@"key"];
        }
        
        [specifier.properties setValue:defaults forKey:@"defaults"];
        
    }
    
    
    
    return original;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    [super setPreferenceValue:value specifier:specifier];

    NSString *key = specifier.properties[@"key"];

    if (key){

        NSString *defaults = specifier.properties[@"defaults"];

        if (defaults){

            //update the CFPreferences so we can read them right away
            CFPreferencesSetAppValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)value, (__bridge CFStringRef)defaults);
            CFPreferencesAppSynchronize((__bridge CFStringRef)defaults);

        }

    }
}

@end




