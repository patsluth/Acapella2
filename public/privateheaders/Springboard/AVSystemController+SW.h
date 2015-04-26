
#define AUDIO_VIDEO_CATEGORY @"Audio/Video"

@interface AVSystemController : NSObject
{
}

+ (id)sharedAVSystemController;

- (BOOL)getVolume:(float *)arg1 forCategory:(id)arg2;
- (BOOL)setVolumeTo:(float)arg1 forCategory:(id)arg2;
- (BOOL)changeVolumeBy:(float)arg1 forCategory:(id)arg2;

@end





@interface AVSystemController(SW)
{
}

+ (void)acapellaChangeVolume:(long)direction;

@end




