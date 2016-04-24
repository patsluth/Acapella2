
@import UIKit;
@import Foundation;





@interface MPUMediaControlsTitlesView : UIView //MPUNowPlayingTitlesView
{
}

@property (weak, nonatomic) UILabel *_titleLabel;
@property (weak, nonatomic) UIView *_titleMarqueeView;
@property (weak, nonatomic) UILabel *_detailLabel;
@property (weak, nonatomic) UIView *_detailMarqueeView;

@property (nonatomic, retain) UIImage *explicitImage;

@property (nonatomic, readonly) long long mediaControlsStyle;

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *artistText;
@property (nonatomic, copy) NSString *albumText;
@property (nonatomic, copy) NSString *stationNameText;

- (id)initWithMediaControlsStyle:(long long)arg1;

- (BOOL)isExplicit;
- (void)setExplicit:(BOOL)arg1;

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)arg1;

@end




