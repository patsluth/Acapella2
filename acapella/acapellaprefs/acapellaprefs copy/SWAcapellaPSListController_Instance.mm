//
//  SWAcapellaPSListController_Instance.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAcapellaPSListController_Instance.h"

#import <Preferences/Preferences.h>





@implementation SWAcapellaPSListController_Instance

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *specifiers = [super loadSpecifiersFromPlistName:plistName target:target];
    return specifiers;
}

@end




