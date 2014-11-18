//
//  SWSelector.h
//  sluthwareioslibrary
//
//  Created by Pat Sluth on 2014-11-14.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#ifndef sluthwareioslibrary_SWSelector_h
#define sluthwareioslibrary_SWSelector_h
#endif

#define SWSuppressPerformSelectorLeakWarning(SW) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
SW; \
_Pragma("clang diagnostic pop") \
} while (0)




