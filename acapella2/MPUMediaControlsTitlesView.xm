
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MPUMediaControlsTitlesView : UIView
{
}

@end





%hook MPUMediaControlsTitlesView //springboard specific

- (void)setFrame:(CGRect)frame
{
    //this tag means we dont want this view to layout
    //when the titles change, layout subviews is called
    //which re-centers the titles view, making the animation look bad
    if (self.tag == 696969){
        return;
    } else if (self.tag == 69){ //only lock the x position
        %orig(CGRectMake(self.frame.origin.x, frame.origin.y, frame.size.width, frame.size.height));
        return;
    }
    
    %orig(frame);
}

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)info
{
    if (info.count == 0){
        info = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                 @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
    }
    
    %orig(info);
}

%end




