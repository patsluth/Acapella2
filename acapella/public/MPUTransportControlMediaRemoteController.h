




@interface MPUTransportControlMediaRemoteController : NSObject
{
}

@property (nonatomic, copy) NSDictionary *nowPlayingInfo;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

//hook this to view media remote command codes
- (void)handlePushingMediaRemoteCommand:(unsigned int)command;

- (id)allowedTransportControlTypes;
- (void)setAllowedTransportControlTypes:(id)x;
- (void)_updateForSupportedCommandsChange;

@end




