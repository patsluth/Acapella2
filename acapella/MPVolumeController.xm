




@interface MPVolumeController : NSObject
{
}

- (float)volumeValue;
- (void)setVolumeValue:(float)arg1;

@end





%hook MPVolumeController

%new
- (void)incrementVolumeInDirection:(NSNumber *)direction
{
    // direction < 0 - decrease
    // direction = 0 - no change
    // direction > 0 - increase
    
    float stepValue = 1.0 / 16.0; //16 is the number of squares in the volume hud
    
    if ([direction integerValue] < 0){
        [self setVolumeValue:[self volumeValue] - stepValue];
    } else if ([direction integerValue] > 0){
        [self setVolumeValue:[self volumeValue] + stepValue];
    }
}

%end




