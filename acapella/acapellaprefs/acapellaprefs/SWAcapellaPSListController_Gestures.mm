//
//  SWAcapellaPSListController_Gestures.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>

#import "SWPSListController.h"





@interface SWAcapellaPSListController_Gestures : SWPSListController
{
}

//so we can keep track of which gestures specifies are showing
@property (strong, nonatomic) NSArray *currentSpecifiersForGesture;

@property (strong, nonatomic) NSMutableArray *allActionTitles;
@property (strong, nonatomic) NSMutableArray *allActionValues;

@end





@implementation SWAcapellaPSListController_Gestures

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setGestureType:@"Tap"]; //Make sure this is set to the default value in this classes plist!
}

//- (void)suspend
//{
//    self.currentSpecifiersForGesture = nil;
//    //[self reloadSpecifiers];
//    
//    [super suspend];
//}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target
{
    NSArray *returnValue = [super loadSpecifiersFromPlistName:plistName target:target];

    //this controllers base key
    NSString *baseKey = [self.specifier.properties valueForKey:@"key"];

    
    for (PSSpecifier *spec in returnValue){ //override default for specific instances
        
        
        //*****
        //Defaults for individual instances
        //*****
        
        NSDictionary *defaultActionValuesForBaseKey = [spec.properties valueForKey:@"defaultActionValuesForBaseKey"];
        
        if (defaultActionValuesForBaseKey){
            
            NSString *defaultValueForBaseKey = [defaultActionValuesForBaseKey valueForKey:baseKey];
            
            if (defaultValueForBaseKey){ //set the default if it is in the dictionary
                [spec.properties setValue:defaultValueForBaseKey forKey:@"default"];
            }
            
        }
        
        
        if (![spec.properties valueForKey:@"default"]){
            [spec.properties setValue:@"action_nil" forKey:@"default"];
        }
        
        
        //*****
        //Removeal of invalid actions keys for individual instances
        //*****
        
        NSDictionary *invalidActionValuesForBaseKey = [spec.properties valueForKey:@"invalidActionValuesForBaseKey"];
        
        if (invalidActionValuesForBaseKey){
            
            NSArray *invalidActionsForBaseKey = [invalidActionValuesForBaseKey valueForKey:baseKey];
            
            for (id invalidAction in invalidActionsForBaseKey){
                
                if ([self.allActionValues containsObject:invalidAction]){
                    
                    //get the index of the invalid action
                    NSUInteger invalidActionIndex = [self.allActionValues indexOfObject:invalidAction];
                    
                    //remove index from both titles and values array
                    [self.allActionTitles removeObjectAtIndex:invalidActionIndex];
                    [self.allActionValues removeObjectAtIndex:invalidActionIndex];
                    
                }
                
            }
            
        }
        
        
        
    }
    
    return returnValue;
}

- (void)setGestureType:(id)specifier
{
    NSString *plistNameForGesture = [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), specifier];
    NSArray *specifiersForGesture = [self loadSpecifiersFromPlistName:plistNameForGesture target:self];
    
    
    if (self.currentSpecifiersForGesture){
        [self replaceContiguousSpecifiers:self.currentSpecifiersForGesture withSpecifiers:specifiersForGesture animated:YES];
    } else {
        [self addSpecifiersFromArray:specifiersForGesture animated:YES];
    }
    
    
    self.currentSpecifiersForGesture = specifiersForGesture;
}

- (NSArray *)actionTitles:(id)target
{
    return [self.allActionTitles copy];
}

- (NSArray *)actionValues:(id)target
{
    return [self.allActionValues copy];
}

- (NSMutableArray *)allActionTitles
{
    if (!_allActionTitles){
        _allActionTitles = [ @[@"None",
                               @"Heart",
                               @"Previous Track",
                               @"Interval Rewind",
                               @"Play",
                               @"Next Track",
                               @"Interval Forward",
                               @"Up Next",
                               
                               @"Share",
                               @"Shuffle",
                               @"Repeat",
                               @"Contextual",
                               
                               @"Open App",
                               @"Rating",
                               @"Increase Volume",
                               @"Decrease Volume"] mutableCopy];
    }
    
    return _allActionTitles;
}

- (NSMutableArray *)allActionValues
{
    if (!_allActionValues){
        _allActionValues = [ @[@"action_nil",
                               @"action_heart",
                               @"action_previoustrack",
                               @"action_intervalrewind",
                               @"action_playpause",
                               @"action_nexttrack",
                               @"action_intervalforward",
                               @"action_upnext",
                               
                               @"action_share",
                               @"action_toggleshuffle",
                               @"action_togglerepeat",
                               @"action_contextual",
                               
                               @"action_openapp",
                               @"action_showratings",
                               @"action_increasevolume",
                               @"action_decreasevolume"] mutableCopy];
    }
    
    return _allActionValues;
}

#pragma mark Init

- (NSString *)bundlePath
{
    return @"/Library/PreferenceBundles/AcapellaPrefs2.bundle";
}

- (NSString *)displayName
{
    return @"Acapella II";
}

- (NSString *)plistPath
{
    return @"/User/Library/Preferences/com.patsluth.AcapellaPrefs2.plist";
}

@end




