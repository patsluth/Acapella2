
#import <AcapellaKit/AcapellaKit.h>
#import "SWAcapellaPrefsBridge.h"

#import "MPUNowPlayingTitlesView.h"
#import "MPUMediaControlsTitlesView.h"
#import "MusicNowPlayingTitlesView.h"

#import <MediaRemote/MediaRemote.h>



#pragma mark - MPUMediaControlsTitlesView

%hook MPUNowPlayingTitlesView //shared between springboard and music app

- (void)setFrame:(CGRect)frame
{
    %orig(frame);
    
    if (self.superview && [self.superview isKindOfClass:%c(SWAcapellaScrollView)]){
        
        SWAcapellaScrollView *acapellaScrollView = (SWAcapellaScrollView *)self.superview;
        self.center = CGPointMake(acapellaScrollView.contentSize.width / 2.0, acapellaScrollView.contentSize.height / 2.0);
        
    }
}

%end





#pragma mark - MPUMediaControlsTitlesView

%hook MPUMediaControlsTitlesView //springboard specific

- (void)setTitleText:(NSString *)arg1
{
    %orig(arg1);
    
    if ([self.superview isKindOfClass:%c(SWAcapellaScrollView)]){
        
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
}

%end





#pragma mark - MusicNowPlayingTitlesView

%hook MusicNowPlayingTitlesView //music app specific

//1 - 2 lines
//2 - 1 line
- (id)initWithStyle:(int)arg1
{
    if (![[SWAcapellaPrefsBridge valueForKey:@"ma_enabled" defaultValue:@YES] boolValue]){
        return %orig(arg1);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return %orig(arg1);
    }
    
    return %orig(1); //force to 2 lines because of our extra room
}

%end




