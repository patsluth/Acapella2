
#import "SWAcapellaActionsHelper.h"
#import "SWAcapellaSharingFormatter.h"
#import "SWAcapellaPrefsBridge.h"

#import "SWAppLauncher.h"

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
                [acapellaDel action_OpenActivity];
            };
        } else if ([action isEqualToNumber:@7]){
            return ^(){
                [acapellaDel action_ShowPlaylistOptions];
            };
        } else if ([action isEqualToNumber:@8]){
            return ^(){
                [acapellaDel action_OpenApp];
            };
        } else if ([action isEqualToNumber:@9]){
            return ^(){
                [acapellaDel action_ShowRatingsOpenApp];
            };
        } else if ([action isEqualToNumber:@10]){
            return ^(){
                [acapellaDel action_DecreaseVolume];
            };
        } else if ([action isEqualToNumber:@11]){
            return ^(){
                [acapellaDel action_IncreaseVolume];
            };
        }
    }
    
    return nil;
}

+ (void)action_PlayPause:(SWAcapellaActionsCompletionBlock)completion
{
    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
    
    if (completion){
        completion(YES, nil);
    }
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
        
        NSString *itemTitle;
        
        if (resultDict){
            itemTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            MRMediaRemoteSendCommand((direction <= -1) ? kMRPreviousTrack : kMRNextTrack, nil);
            
            if (completion){
                //sometimes when nothing is playing, there is still a result dict with a few empty keys.
                completion(resultDict ? YES : NO, itemTitle ? resultDict : nil);
            }
            
        }];
    });
}

+ (void)action_SkipBackward:(SWAcapellaActionsCompletionBlock)completion
{
    [SWAcapellaActionsHelper changeSongTimeBySeconds:-20 completion:completion];
}

+ (void)action_SkipForward:(SWAcapellaActionsCompletionBlock)completion
{
    [SWAcapellaActionsHelper changeSongTimeBySeconds:20 completion:completion];
}

+ (void)changeSongTimeBySeconds:(double)seconds completion:(SWAcapellaActionsCompletionBlock)completion
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        if (resultDict){
            double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
            MRMediaRemoteSetElapsedTime(mediaCurrentElapsedDuration + seconds);
        }
        
        if (completion){
            completion(resultDict ? YES : NO, resultDict);
        }
    });
}

+ (void)action_OpenActivity:(SWAcapellaActionsCompletionBlock)completion
{
    SBDeviceLockController *deviceLC = [%c(SBDeviceLockController) sharedController];
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *resultDict = (__bridge NSDictionary *)result;
        
        if (resultDict){
            
            NSString *mediaTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
            NSString *mediaArtist = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
            NSData *mediaArtworkData = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
            NSString *sharingHashtag = [%c(SWAcapellaPrefsBridge) valueForKey:@"sharingHashtag" defaultValue:@"acapella"];
            
            NSDictionary *shareData = [%c(SWAcapellaSharingFormatter) formattedShareDictionaryWithMediaTitle:mediaTitle
                                                                                            mediaArtist:mediaArtist
                                                                                       mediaArtworkData:mediaArtworkData
                                                                                         sharingHashtag:sharingHashtag];
            
            if (shareData){
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if (completion){
                        completion(!(deviceLC && deviceLC.isPasscodeLocked), shareData);
                    }
                }];
                
                return;
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
            if (completion){
                completion(NO, nil);
            }
            
        }];
        
    });
}

+ (void)action_OpenApp:(SWAcapellaActionsCompletionBlock)completion
{
    MRMediaRemoteGetNowPlayingApplicationPID(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(int PID){
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            SBApplication *nowPlayingApp = [[%c(SBApplicationController) sharedInstance] applicationWithPid:PID];
            
            if (!nowPlayingApp){ //fallback
                nowPlayingApp = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.apple.Music"];
            }
            
            [%c(SWAppLauncher) launchAppLockscreenFriendly:nowPlayingApp];
            
            if (completion){
                completion(nowPlayingApp ? YES : NO, nil);
            }
            
        }];
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

+ (void)action_DecreaseVolume:(SWAcapellaActionsCompletionBlock)completion
{
    [%c(AVSystemController) acapellaChangeVolume:-1];
    
    if (completion){
        completion(YES, nil);
    }
}

+ (void)action_IncreaseVolume:(SWAcapellaActionsCompletionBlock)completion
{
    [%c(AVSystemController) acapellaChangeVolume:1];
    
    if (completion){
        completion(YES, nil);
    }
}

@end




