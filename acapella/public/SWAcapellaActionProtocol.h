
typedef void(^swAcapellaAction)();

@protocol SWAcapellaActionProtocol <NSObject>

@required
- (void)action_PlayPause;
- (void)action_PreviousSong;
- (void)action_NextSong;
- (void)action_SkipBackward;
- (void)action_SkipForward;
- (void)action_OpenActivity;
- (void)action_ShowPlaylistOptions;
- (void)action_OpenAppShowRatings;
- (void)action_ShowRatingsOpenApp;
- (void)action_DecreaseVolume;
- (void)action_IncreaseVolume;

//helper
- (swAcapellaAction)methodForAction:(NSNumber *)action;
- (void)skipSongInDirection:(int)direction;
- (void)changeSongTimeBySeconds:(double)seconds;

@optional

@end




