




@interface MPUTransportControlMediaRemoteController : NSObject
{
}

@property (nonatomic, assign, getter=isPlaying) BOOL playing;

//hook this to view media remote command codes
- (void)handlePushingMediaRemoteCommand:(unsigned int)command;

@end




