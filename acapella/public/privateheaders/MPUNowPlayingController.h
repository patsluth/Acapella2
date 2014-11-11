
@interface MPUNowPlayingController : NSObject
{
}


@property(readonly, nonatomic) NSString *nowPlayingAppDisplayID;
@property(readonly, nonatomic) UIImage *currentNowPlayingArtwork;
@property(readonly, nonatomic) NSDictionary *currentNowPlayingInfo;

@end




