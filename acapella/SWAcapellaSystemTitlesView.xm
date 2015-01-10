
#import <AcapellaKit/AcapellaKit.h>

#import "MusicNowPlayingTitlesView.h" //needed to distinguish between music app labels and system media control labels

#import <MediaRemote/MediaRemote.h>
#import <AppList/ALApplicationList.h>
#import <Springboard/Springboard.h>



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
    
    [self updateDetailText];
}


- (void)setAlbumText:(id)arg1
{
    %orig(arg1);
    
    [self updateDetailText];
}

- (void)setArtistText:(id)arg1
{
    %orig(arg1);
    
    [self updateDetailText];
}

%new
- (void)updateDetailText
{
    //dont affect the music app.
    if (self.window.rootViewController &&
        [self.window.rootViewController isKindOfClass:NSClassFromString(@"MPHRootViewController")]){
        return;
    }
    
    //make sure only our title text is set. Then see if the title text equals an app name
    if (!self.artistText || [self.artistText isEqualToString:@""]){
        if (!self.albumText || [self.albumText isEqualToString:@""]){
            
            if (self.titleText && ![self.titleText isEqualToString:@""]){
                
                NSDictionary *appList = [%c(ALApplicationList) sharedApplicationList].applications;
                
                if (appList){
                    for (NSString *appName in appList){
                        if ([self.titleText isEqualToString:[appList valueForKey:appName]]){
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self setArtistText:@"Tap To Play"];
                                [self setAlbumText:@"Acapella"];
                                [self sizeToFit];
                                [self layoutSubviews];
                            }];
                            
                            return;
                        }
                    }
                }
            } else {
                
                //special situtation. If we skep a song and the music stops, the app name no longer shows
                //APPLE BUG
                MRMediaRemoteGetNowPlayingApplicationPID(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(int pid){
                    
                    SBApplicationController *sbAppController = [%c(SBApplicationController) sharedInstanceIfExists];
                    
                    if (sbAppController){
                        
                        SBApplication *nowPlayingApp = [sbAppController applicationWithPid:pid];
                        
                        if (nowPlayingApp){
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                //[self setTitleText:nowPlayingApp.displayName];
                                [self setArtistText:@"Tap To Play"];
                                [self setAlbumText:@"Acapella"];
                                [self sizeToFit];
                                [self layoutSubviews];
                            }];
                            
                        } else {
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self setTitleText:@"Music"];
                                [self setArtistText:@"Tap To Play"];
                                [self setAlbumText:@"Acapella"];
                                [self sizeToFit];
                                [self layoutSubviews];
                            }];
                        }
                        
                    } else {
                        //fallback?
                    }
                    
                });
                
            }
            
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    if (self.superview && [self.superview isKindOfClass:[UIScrollView class]]){
        
        UIScrollView *superScrollView = (UIScrollView *)self.superview;
        
        if (superScrollView.delegate && [superScrollView.delegate isKindOfClass:%c(SWAcapellaBase)]){
            
            SWAcapellaBase *acapella = (SWAcapellaBase *)superScrollView.delegate;
            
            %orig(CGRectMake((superScrollView.contentSize.width / 2) - (frame.size.width / 2),
                             (acapella.frame.size.height / 2) - (frame.size.height / 2),
                             frame.size.width,
                             frame.size.height));
            
            return;
        }
        
    }
    
    %orig(frame);
}

%end




