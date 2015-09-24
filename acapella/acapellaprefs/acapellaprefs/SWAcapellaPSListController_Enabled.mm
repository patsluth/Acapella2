//
//  SWAcapellaPSListController_Enabled.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "libsw/SWPSListController.h"





@interface SWAcapellaPSListController_Enabled : SWPSListController
{
}

@end





@implementation SWAcapellaPSListController_Enabled

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *original = [super loadSpecifiersFromPlistName:plistName target:target];
    
    return original;
}

@end




