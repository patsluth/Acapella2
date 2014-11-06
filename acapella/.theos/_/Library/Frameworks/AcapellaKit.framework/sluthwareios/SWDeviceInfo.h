//
//  SWDeviceInfo.h
//  sluthwareioslibrary
//
//  Created by Pat Sluth on 2014-11-02.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWDeviceInfo : NSObject

+ (NSArray *)iOSVersion;

//returns separate ios version parts. returns - if not applicable
+ (NSInteger)iOSVersion_First;
+ (NSInteger)iOSVersion_Second;
+ (NSInteger)iOSVersion_Third;

@end




