
@class MPAVController;
@class MPAVItem;

@interface MusicNowPlayingViewController : UIViewController <SWAcapellaDelegate>
{
    //MPAVController *_player; //iOS 8 only
                                //we can use the same variable on _playbackControlsView
                                //so we can use the same code on both iOS versions
    MPAVItem *_item; //iOS 7 & 8
}

//@property (retain) MPAVController *player;  //iOS 8 only



//- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2;
//- (void)didRotateFromInterfaceOrientation:(int)arg1;
//PREVIOUS IPAD

- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2; //iOS 7 & 8

@end





@interface MusicNowPlayingViewController(SW)
{
}

//new
@property (strong, nonatomic) SWAcapellaBase *acapella;

- (UIView *)playbackControlsView;
- (MPAVController *)player;
- (UISlider *)progressControl;
- (UIView *)transportControls;
- (UISlider *)volumeSlider;
- (UIView *)ratingControl;
- (UIView *)titlesView;
- (UIView *)repeatButton;
- (UIImageView *)artworkView;
- (MPAVItem *)mpavItem;
- (UIButton *)likeOrBanButton;

@end




