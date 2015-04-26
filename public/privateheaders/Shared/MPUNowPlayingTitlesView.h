
#import <UIKit/UIKit.h>

//used in all three. MPUMediaControlsTitlesView is subclass for LS and CC.
//MusicNowPlayingTitlesView is subclass for Music app
@interface MPUNowPlayingTitlesView : UIView
{
	NSString *_titleText;
	UILabel *_titleLabel;
    UILabel *_detailLabel;
    
    BOOL _explicit;
	UIImageView *_explicitImageView;
}

- (id)initWithStyle:(int)arg1;

@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *artistText;
@property (nonatomic, copy) NSString *albumText;

- (void)setTitleText:(NSString *)arg1;
- (void)setArtistText:(NSString *)arg1;
- (void)setAlbumText:(NSString *)arg1;

- (UILabel *)_titleLabel;
- (UILabel *)_detailLabel;

- (BOOL)isExplicit;
- (void)setExplicit:(BOOL)arg1;
- (void)setExplicitImage:(UIImage *)arg1;

@end




