//
//  main.m
//  acapellaprefdefaults
//
//  Created by Pat Sluth on 2015-10-17.
//  Copyright © 2015 Pat Sluth. All rights reserved.
//





#import <Foundation/Foundation.h>





static id prefValueForKey(NSString *key)
{
    NSArray *parts = [key componentsSeparatedByString:@"_"];
    
    if (parts.count < 2) {
        NSLog(@"Invalid Key %@", key);
        return nil;
    }
    
    //NSString *app = [parts objectAtIndex:0]; // acapella2
    NSString *prefix = [parts objectAtIndex:1]; //cc, ls, etc..
    NSString *option = [parts objectAtIndex:2];
    
    if ([option isEqualToString:@"enabled"]) {
        return @(YES);
    } else if ([option isEqualToString:@"gestures"]) {
        
//        if (parts.count < 5) {
//            NSLog(@"Invalid Gesture Key %@", key);
//            return nil;
//        }
        
        NSString *gesture = [parts objectAtIndex:3];
        
        if ([gesture containsString:@"tap"]) {
            
            //no volume control for mini
            if ([gesture containsString:@"centre"] || [prefix isEqualToString:@"musicmini"]) {
                return @"action_playpause";
            } else {
                if ([gesture containsString:@"left"]) {
                    return @"action_decreasevolume";
                } else if ([gesture containsString:@"right"]) {
                    return @"action_increasevolume";
                }
            }
            
        } else if ([gesture containsString:@"swipe"]) {
            
            if ([gesture containsString:@"left"]) {
                return @"action_nexttrack";
            } else if ([gesture containsString:@"right"]) {
                return @"action_previoustrack";
            }
            
        } else if ([gesture containsString:@"press"] || [gesture containsString:@"popaction"]) {
            
            if ([gesture containsString:@"left"]) {
                return @"action_intervalrewind";
            } else if ([gesture containsString:@"centre"]) {
                
                if ([prefix isEqualToString:@"musicnowplaying"]) {
                    return @"action_showratings";
                } else if ([prefix isEqualToString:@"musicmini"]) {
                    return @"action_contextual";
                } else {
                    return @"action_openapp";
                }
                
            } else if ([gesture containsString:@"right"]) {
                return @"action_intervalforward";
            }
            
        }
        
        //should never hit this
        NSLog(@"Error parsing gesture key %@", key);
        return @"action_nil";
        
    } else if ([option isEqualToString:@"progressslider"]) {
        
        if ([prefix isEqualToString:@"cleo"]) {
            return @(NO);
        } else {
            return @(YES);
        }
        
    } else if ([option isEqualToString:@"transport"]) {
        
        if (parts.count < 3) {
            NSLog(@"Invalid Transport Key %@", key);
            return nil;
        }
        
        if ([prefix isEqualToString:@"musicmini"] ||
            [prefix isEqualToString:@"cleo"]) { //all transport controls disabled for mini and cleo
            return @(NO);
        }
        
        NSString *transport = [parts objectAtIndex:3];
        
        if ([transport isEqualToString:@"heart"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"previoustrack"]) {
            return @(NO);
        } else if ([transport isEqualToString:@"intervalrewind"]) {
            return @(NO);
        } else if ([transport isEqualToString:@"playpause"]) {
            return @(NO);
        } else if ([transport isEqualToString:@"nexttrack"]) {
            return @(NO);
        } else if ([transport isEqualToString:@"intervalforward"]) {
            return @(NO);
        } else if ([transport isEqualToString:@"upnext"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"share"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"shuffle"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"repeat"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"contextual"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"playbackrate"]) {
            return @(YES);
        } else if ([transport isEqualToString:@"sleeptimer"]) {
            return @(YES);
        }
        
    } else if ([option isEqualToString:@"volumeslider"]) {
        
        if ([prefix isEqualToString:@"cleo"]) {
            return @(NO);
        } else {
            return @(YES);
        }
        
    }
    
    return @"";
}

static void writeKey(NSString *key, id value, NSString *directory)
{
    NSString *filePath = [NSString stringWithFormat:@"%@prefsDefaults.plist", directory];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
    
    [dict setValue:value forKey:key];
    [dict writeToFile:filePath atomically:YES];
    
//    if (![dict valueForKey:key]) {
//        //New Key
//    } else {
//        //Key Exists
//    }
    
}

static void exportKeys(NSString *directory, NSString *detail, NSString *prevKey)
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@%@.plist", directory, detail]];
    
    
    if (!dict && prevKey) { //no detail, output the key
        
        writeKey(prevKey, prefValueForKey(prevKey), directory);
        
    } else {
        
        NSArray *items = [dict valueForKey:@"items"];
        
        for (NSDictionary *item in items) {
            
            NSString *key = [item valueForKey:@"key"];
            NSString *subDetail = [item valueForKey:@"detail"];
            
            if (prevKey && key) { //append keys
                key = [NSString stringWithFormat:@"%@_%@", prevKey, key];
            }
            
            if (subDetail) { //keep drilling down
                
                [item setValue:key forKey:@"key"];
                exportKeys(directory, subDetail, key);
                
            } else { //this is the final detail, output the key
                
                if (key) {
                    writeKey(key, prefValueForKey(key), directory);
                }
                
            }
            
        }
        
    }
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        //get data from standart input. In the form 'DIRECTORY;ROOTDETAIL'
        NSFileHandle *standardInput = [NSFileHandle fileHandleWithStandardInput];
        NSString *input = [[NSString alloc] initWithData:[standardInput readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        NSArray *arguments = [input componentsSeparatedByString:@";"];
        
        if (arguments.count > 2) {
            
            NSString *directory = [NSString stringWithFormat:@"%@/Resources/", arguments[0]];
            NSString *rootDetail = arguments[1];
            
            NSLog(@"Acapella Prefs: Exporting Default Keys");
            exportKeys(directory, rootDetail, nil);
            
        }
    }
    
    return 0;
}




