//
//  main.m
//  acapellaprefdefaults
//
//  Created by Pat Sluth on 2015-10-17.
//  Copyright © 2015 Pat Sluth. All rights reserved.
//





#import <Foundation/Foundation.h>





static void writeKey(NSString *key, NSString *directory)
{
    NSString *filePath = [NSString stringWithFormat:@"%@defaultPrefs.plist", directory];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
    
    if (![dict valueForKey:key]){
        //Adding Key
        [dict setValue:@"valuebitch" forKey:key];
        [dict writeToFile:filePath atomically:YES];
    } else {
        //Key Exists
    }
}

static void exportKeys(NSString *directory, NSString *detail, NSString *prevKey)
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@%@.plist", directory, detail]];
    
    if (!dict && prevKey){ //no detail, output the key
        
        writeKey(prevKey, directory);
        
    } else {
        
        NSArray *items = [dict valueForKey:@"items"];
        
        for (NSDictionary *d in items){
            
            NSString *key = [d valueForKey:@"key"];
            NSString *subDetail = [d valueForKey:@"detail"];
            
            if (prevKey && key){ //append keys
                key = [NSString stringWithFormat:@"%@_%@", prevKey, key];
            }
            
            if (subDetail){ //keep drilling down
                
                [d setValue:key forKey:@"key"];
                exportKeys(directory, subDetail, key);
                
            } else { //this is the final detail, output the key
                
                if (key){
                    writeKey(key, directory);
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
        
        if (arguments.count > 2){
            
            NSString *directory = [NSString stringWithFormat:@"%@/Resources/", arguments[0]];
            NSString *rootDetail = arguments[1];
            
            NSLog(@"Exporting Default Keys");
            exportKeys(directory, rootDetail, nil);
            
        }
        
    }
    return 0;
}




