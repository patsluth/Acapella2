//
//  SWAcapellaPSListController_Instance.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAcapellaPSListController_Instance.h"

#import <Preferences/Preferences.h>





@interface SWAcapellaPSListController_ControlCenter : SWAcapellaPSListController_Instance
{
}

@end





@implementation SWAcapellaPSListController_ControlCenter

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *specifiers = [super loadSpecifiersFromPlistName:plistName target:target];
    
    NSLog(@"PAT TEST SPECDS %@", specifiers);
    
    return specifiers;
}

@end




