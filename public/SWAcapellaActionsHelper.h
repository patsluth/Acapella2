
typedef void(^swAcapellaAction)();

@protocol SWAcapellaActionProtocol <NSObject>

@required

- (void)action_PlayPause;
- (void)action_PreviousSong;
- (void)action_NextSong;
- (void)action_SkipBackward;
- (void)action_SkipForward;
- (void)action_ShowRatings;
- (void)action_DecreaseVolume;
- (void)action_IncreaseVolume;

@optional

@end




typedef void(^SWAcapellaActionsCompletionBlock)(BOOL successful, id object); //block to be called when action is completed

@interface SWAcapellaActionsHelper : NSObject

+ (swAcapellaAction)methodForAction:(NSNumber *)action withDelegate:(id<SWAcapellaActionProtocol>)acapellaDel;

//base actions
+ (void)action_PlayPause:(SWAcapellaActionsCompletionBlock)completion;

+ (void)action_PreviousSong:(SWAcapellaActionsCompletionBlock)completion;
+ (void)action_NextSong:(SWAcapellaActionsCompletionBlock)completion;
+ (void)skipSongInDirection:(int)direction completion:(SWAcapellaActionsCompletionBlock)completion;

+ (void)action_SkipBackward;
+ (void)action_SkipForward;
+ (void)changeSongTimeBySeconds:(double)seconds;

+ (void)isCurrentItemRadioItem:(SWAcapellaActionsCompletionBlock)completion;

+ (void)action_DecreaseVolume;
+ (void)action_IncreaseVolume;

@end




