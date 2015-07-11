




%hook MPUMediaControlsTitlesView //springboard specific

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)info
{
    if (info.count == 0){
        info = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                 @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
    }
    
    %orig(info);
}

%end




