
#import "SWAcapellaActionsHelper.h"
#import "SWAcapellaPrefsBridge.h"

#import <Springboard/Springboard.h>
#import <MediaRemote/MediaRemote.h>
#import "AVSystemController+SW.h"

@implementation SWAcapellaActionsHelper

+ (swAcapellaAction)methodForAction:(NSNumber *)action withDelegate:(id<SWAcapellaActionProtocol>)acapellaDel
{
    if (acapellaDel){
        if ([action isEqualToNumber:@1]){
            return ^(){
                [acapellaDel action_PlayPause];
            };
        } else if ([action isEqualToNumber:@2]){
            return ^(){
                [acapellaDel action_PreviousSong];
            };
        } else if ([action isEqualToNumber:@3]){
            return ^(){
                [acapellaDel action_NextSong];
            };
        } else if ([action isEqualToNumber:@4]){
            return ^(){
                [acapellaDel action_SkipBackward];
            };
        } else if ([action isEqualToNumber:@5]){
            return ^(){
                [acapellaDel action_SkipForward];
            };
        } else if ([action isEqualToNumber:@6]){
            return ^(){
                [acapellaDel action_ShowRatings];
            };
        } else if ([action isEqualToNumber:@7]){
            return ^(){
                [acapellaDel action_DecreaseVolume];
            };
        } else if ([action isEqualToNumber:@8]){
            return ^(){
                [acapellaDel action_IncreaseVolume];
            };
        }
    }
    
    return nil;
}

+ (void)action_PlayPause:(SWAcapellaActionsCompletionBlock)completion
{
    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(Boolean isPlaying){
        
        MRMediaRemoteSendCommand(isPlaying ? kMRPause : kMRPlay, nil);
        
        if (completion){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                completion(YES, nil);
            });
        }
        
    });
}

+ (void)action_PreviousSong:(SWAcapellaActionsCompletionBlock)completion
{
    [SWAcapellaActionsHelper skipSongInDirection:-1 completion:completion];
}

+ (void)action_NextSong:(SWAcapellaActionsCompletionBlock)completion
{
    [SWAcapellaActionsHelper skipSongInDirection:1 completion:completion];
}

+ (void)skipSongInDirection:(int)direction completion:(SWAcapellaActionsCompletionBlock)completion
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        //NSString *itemTitle;
        
        if (resultDict){
        //    itemTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
        }
        
        MRMediaRemoteSendCommand((direction <= -1) ? kMRPreviousTrack : kMRNextTrack, nil);
        
        //if (completion){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                if(completion){
                    completion(YES, nil);
                }
                
                //sometimes when nothing is playing, there is still a result dict with a few empty keys.
                //completion(resultDict ? YES : NO, itemTitle ? resultDict : nil);
            });
        //}
        
    });
}

+ (void)action_SkipBackward
{
    [SWAcapellaActionsHelper changeSongTimeBySeconds:-20];
}

+ (void)action_SkipForward
{
    [SWAcapellaActionsHelper changeSongTimeBySeconds:20];
}

+ (void)changeSongTimeBySeconds:(double)seconds
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        if (resultDict){
            double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
            MRMediaRemoteSetElapsedTime(mediaCurrentElapsedDuration + seconds);
        }
    });
}

+ (void)isCurrentItemRadioItem:(SWAcapellaActionsCompletionBlock)completion
{
    
    //TODO: kMRMediaRemoteNowPlayingInfoMediaType = kMRMediaRemoteMediaTypeITunesRadio;
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        NSString *itemTitle;
        NSString *mediaRadioStationID;
        
        if (resultDict){
            itemTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
            mediaRadioStationID = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRadioStationIdentifier];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (completion){
                //sometimes when nothing is playing, there is still a result dict with a few empty keys.
                completion(mediaRadioStationID ? YES : NO, itemTitle ? resultDict : nil);
            }
        }];
        
    });
}

+ (void)action_DecreaseVolume
{
    [%c(AVSystemController) acapellaChangeVolume:-1];
}

+ (void)action_IncreaseVolume
{
    [%c(AVSystemController) acapellaChangeVolume:1];
}

@end




