
@interface MusicNowPlayingViewController : UIViewController <SWAcapellaDelegate>
{
}

//- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2;
//- (void)didRotateFromInterfaceOrientation:(int)arg1;
//PREVIOUS IPAD

//- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2;

@end





@interface MusicNowPlayingViewController(SW)
{
}

//new
@property (strong, nonatomic) SWAcapellaBase *acapella;

- (UIView *)playbackControlsView;
- (UIView *)progressControl;
- (UIView *)transportControls;
- (UIView *)volumeSlider;
- (UIView *)ratingControl;
- (UIView *)titlesView;
- (UIImageView *)artworkView;

@end




