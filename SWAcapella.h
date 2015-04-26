
#import "libSluthware.h"

#define SW_ACAPELLA_LEFTRIGHT_VIEW_BOUNDARY_PERCENTAGE 0.20

SW_INLINE NSString *NSStringForRepeatMode(int repeatMode)
{
    if (repeatMode == 0){
        return @"Repeat Off";
    } else if (repeatMode == 1){
        return @"Repeat One";
    } else if (repeatMode == 2){
        return @"Repeat All";
    }
    
    return @"";
}

SW_INLINE NSString *NSStringForShuffleMode(int shuffleMode)
{
    if (shuffleMode == 0){
        return @"Shuffle";
    } else if (shuffleMode == 2){
        return @"Shuffle All";
    }
    
    return @"";
}




