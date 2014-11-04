
@interface SBMediaController
{
    NSDictionary *_nowPlayingInfo;
}

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
- (BOOL)endSeek:(int)arg1;
- (BOOL)beginSeek:(int)arg1;
- (BOOL)changeTrack:(int)arg1;

- (id)nowPlayingApplication;
- (id)mediaControlsDestinationApp;
- (BOOL)trackIsBeingPlayedByMusicApp;

- (void)setCurrentTrackTime:(float)arg1;
- (double)trackElapsedTime;
- (double)trackDuration;
- (id)nowPlayingAlbum;
- (id)nowPlayingTitle;
- (id)nowPlayingArtist;

- (BOOL)isRadioTrack;

- (id)_nowPlayingInfo;

@end




