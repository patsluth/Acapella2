
#import "MusicNowPlayingTitlesView.h"



//%hook MPUMediaControlsTitlesView
////1 - ControlCenter default (white primary text, black secondary text)
////2 - LockScreen default (white primary text, grey secondary text)
//- (id)initWithMediaControlsStyle:(int)arg1
//{
//    return %orig(arg1);
//}
//%end



%hook MPUNowPlayingTitlesView

//1 - 2 lines
//2 - 1 line
- (id)initWithStyle:(int)arg1
{
    if ([self isKindOfClass:%c(MusicNowPlayingTitlesView)] && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)){
        return %orig(arg1);
    }
    
    return %orig(1); //force to 2 lines because of our extra room
}

- (void)setTitleText:(NSString *)arg1
{
    %orig(arg1);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText" object:self];
}

%end