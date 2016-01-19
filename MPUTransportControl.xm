//
//  MPUTransportControl.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//





@interface MPUTransportControl : NSObject
{
}

@property (nonatomic) BOOL acceptsTapsWhenDisabled;

@end





%hook MPUTransportControl

// fix for podcast play button not allowing tapOnControlType to be invoked
- (BOOL)acceptsTapsWhenDisabled
{
    return YES;
}

%end




