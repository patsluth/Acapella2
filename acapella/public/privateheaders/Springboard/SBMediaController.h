
@class SBApplication;

@interface SBMediaController : NSObject
{
    NSDictionary *_nowPlayingInfo;
}

@property(readonly, assign, nonatomic) SBApplication *nowPlayingApplication;  //iOS 8
- (id)nowPlayingApplication; //iOS7
- (id)mediaControlsDestinationApp; //iOS7
- (BOOL)trackIsBeingPlayedByMusicApp; //iOS7

+ (BOOL)applicationCanBeConsideredNowPlaying:(id)arg1;
+ (id)sharedInstance;

- (BOOL)toggleShuffle;
- (BOOL)toggleRepeat;
- (int)shuffleMode;
- (int)repeatMode;

- (BOOL)stop;
- (BOOL)togglePlayPause;
- (BOOL)pause;
- (BOOL)isPaused;
- (BOOL)play;
- (BOOL)setPlaybackSpeed:(int)speed;
- (BOOL)endSeek:(int)arg1;
- (BOOL)beginSeek:(int)arg1;
- (BOOL)changeTrack:(int)arg1;

- (BOOL)isRadioTrack; //iOS 7 only

- (id)_nowPlayingInfo;

@end




