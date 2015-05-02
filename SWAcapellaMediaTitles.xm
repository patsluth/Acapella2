
#import "MPUNowPlayingTitlesView.h"
#import "MPUMediaControlsTitlesView.h"
#import "MusicNowPlayingTitlesView.h"

#import <MediaRemote/MediaRemote.h>



#pragma mark - MPUMediaControlsTitlesView

%hook MPUNowPlayingTitlesView //shared between springboard and music app

//1 - 2 lines
//2 - 1 line
- (id)initWithStyle:(int)arg1
{
    if ([self isKindOfClass:%c(MusicNowPlayingTitlesView)] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)){
        return %orig(arg1);
    }
    
    return %orig(1); //force to 2 lines because of our extra room
}

%end





#pragma mark - MPUMediaControlsTitlesView

%hook MPUMediaControlsTitlesView //springboard specific

- (void)setTitleText:(NSString *)arg1
{
    %orig(arg1);
    
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!result){
                
                [self setArtistText:@"Tap to Play"];
                [self setAlbumText:@"Acapella"];
                
                [self setNeedsDisplay];
                
            }
        });
    });
}

%end





#pragma mark - MusicNowPlayingTitlesView

%hook MusicNowPlayingTitlesView //music app specific

//1 - 2 lines
//2 - 1 line
- (id)initWithStyle:(int)arg1
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return %orig(arg1);
    }
    
    return %orig(1); //force to 2 lines because of our extra room
}

%end




