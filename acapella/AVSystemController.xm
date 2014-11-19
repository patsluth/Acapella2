
#import "AVSystemController+SW.h"
#import "UIApplication+SW.h"

%hook AVSystemController

%new
+ (void)acapellaChangeVolume:(long)direction
{
    AVSystemController *avsc = [%c(AVSystemController) sharedAVSystemController];

    if (avsc){ //0.0625 = 1 / 16 (number of squares in iOS HUD)
        [[UIApplication sharedApplication] setSystemVolumeHUDEnabled:NO forAudioCategory:AUDIO_VIDEO_CATEGORY];
        [avsc changeVolumeBy:0.0625 * direction forCategory:AUDIO_VIDEO_CATEGORY];
    }
}

%end




