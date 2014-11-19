
@class MPQueuePlayer;
@class MPAVItem;
@class MPMediaItem;
@class MPMediaQuery;

@interface MPAVController : NSObject
{
}

//@property(readonly) AVAudioSessionMediaPlayerOnly *_playerAVAudioSession;
@property(readonly) unsigned int activeRepeatType;
@property(readonly) unsigned int activeShuffleType;

@property(readonly) MPQueuePlayer *avPlayer;
@property(readonly) MPAVItem *currentItem;
@property(readonly) MPMediaItem *currentMediaItem;
@property(readonly) MPMediaQuery *currentMediaQuery;

- (void)applyRepeatSettings;
- (void)applyShuffleSettings;
- (void)setRepeatType:(unsigned int)arg1;
- (void)setShuffleType:(unsigned int)arg1;

- (void)changePlaybackIndexBy:(long)arg1
                    deltaType:(int)arg2
            ignoreElapsedTime:(BOOL)arg3
allowSkippingUnskippableContent:(BOOL)arg4;
- (void)changePlaybackIndexBy:(long)arg1;

- (BOOL)canSeekBackwards;//iOS 7 & 8
- (BOOL)canSeekForwards; //iOS 7 & 8
- (void)beginSeek:(int)arg1; //iOS 7 & 8
- (void)endSeek; //iOS 7 & 8

- (MPAVItem *)currentItem;
- (MPMediaItem *)currentMediaItem;
- (MPMediaQuery *)currentMediaQuery;

- (BOOL)isPlaying;
- (void)play;
- (void)togglePlayback;
- (void)togglePlaybackWithOptions:(long long)arg1;
- (void)pause;
- (void)pauseWithFadeout:(float)arg1;
- (BOOL)isSeekingOrScrubbing;



- (void)playItemAtIndex:(unsigned int)arg1 forceRestart:(BOOL)arg2;
- (void)playItemAtIndex:(unsigned int)arg1 withOptions:(long long)arg2;
- (void)playItemAtIndex:(unsigned int)arg1;
- (void)playWithOptions:(long long)arg1;

- (void)setPlaybackIndex:(int)arg1 selectionDirection:(int)arg2;
- (void)setPlaybackIndex:(int)arg1;
- (void)setPlaybackMode:(int)arg1;

@end




