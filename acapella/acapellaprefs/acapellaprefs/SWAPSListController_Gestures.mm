//
//  SWAPSListController_Gestures.mm
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWAPSListController.h"

#import <Preferences/Preferences.h>





@interface SWAPSListController_Gestures : SWAPSListController
{
}

@property (strong, nonatomic) NSMutableArray *allActionTitles;
@property (strong, nonatomic) NSMutableArray *allActionValues;

@end





@implementation SWAPSListController_Gestures

//    NSArray *original = [super loadSpecifiersFromPlistName:plistName target:target];
//    
//    //this controllers base key
//    NSString *baseKey = [self.specifier.properties valueForKey:@"key"];
//    
//    for (PSSpecifier *spec in original){ //override default for specific instances
//        
//        
//        //*****
//        //Defaults for individual instances
//        //*****
//        
//        NSDictionary *defaultActionValuesForBaseKey = [spec.properties valueForKey:@"defaultActionValuesForBaseKey"];
//        
//        if (defaultActionValuesForBaseKey){
//            
//            NSString *defaultValueForBaseKey = [defaultActionValuesForBaseKey valueForKey:baseKey];
//            
//            if (defaultValueForBaseKey){ //set the default if it is in the dictionary
//                [spec.properties setValue:defaultValueForBaseKey forKey:@"default"];
//            }
//            
//        }
//        
//        
//        if (![spec.properties valueForKey:@"default"]){
//            [spec.properties setValue:@"action_nil" forKey:@"default"];
//        }
//        
//    }
//    
//    return original;
//}

- (NSArray *)actionTitles:(id)target
{
    return [self.allActionTitles copy];
}

- (NSArray *)actionValues:(id)target
{
    return [self.allActionValues copy];
}

- (void)removeInvalidActions
{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[self.bundle pathForResource:NSStringFromClass([self class])
                                                                                           ofType:@"plist"]];
    NSDictionary *invalidActionValuesForBaseKey = [plist valueForKey:@"invalidActionValuesForBaseKey"];
    
    //this controllers base key
    NSString *baseKey = [self.specifier.properties valueForKey:@"key"];
    
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
                               @"Decrease Volume",
                               @"EqualizerEverywhere"] mutableCopy];
        
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
                               @"action_decreasevolume",
                               @"action_equalizereverywhere"] mutableCopy];
        
        [self removeInvalidActions];
        
    }
    
    return _allActionValues;
}

@end




