
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MusicNowPlayingTitlesView : UIView
{
}

@end





%hook MusicNowPlayingTitlesView

- (void)setFrame:(CGRect)frame
{
    //this tag means we dont want this view to layout
    //when the titles change, layout subviews is called
    //which re-centers the titles view, making the animation look bad
    if (self.tag == 696969){
        return;
    }
    
    %orig(frame);
}

%end




