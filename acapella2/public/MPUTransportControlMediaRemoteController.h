




@interface MPUTransportControlMediaRemoteController : NSObject
{
}

@property (nonatomic, copy) NSDictionary *nowPlayingInfo;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

//hook this to view media remote command codes
- (void)handlePushingMediaRemoteCommand:(unsigned int)command;
//0 Play
//1 Pause
//2 Stop
//3 TogglePlayPause
//4 Skip Forward
//5 Skip Backwards

- (void)_updateForSupportedCommandsChange;

@end




