
#import <UIKit/UIKit.h>

@class SWAcapellaPlaylistOptions;




@protocol SWAcapellaPlaylistOptionsDelegate <NSObject>

@required
//0 = repeat
//1 = genius
//2 = shuffle
- (void)swAcapellaPlaylistOptions:(SWAcapellaPlaylistOptions *)view buttonTapped:(UIButton *)button withIndex:(NSInteger)index;

@end





@interface SWAcapellaPlaylistOptions : NSObject
{
}

@property (weak, nonatomic) id<SWAcapellaPlaylistOptionsDelegate> delegate;
@property (readwrite, nonatomic) BOOL shouldShowGeniusButton;

- (void)create;
- (BOOL)created;
- (void)cleanup;
- (void)layoutToScrollView:(UIScrollView *)scrollview;
- (void)startHideTimer;
- (void)stopHideTimer;

- (UIButton *)updateButtonAtIndex:(NSInteger)index
                             text:(NSString *)text
                             font:(UIFont *)font
                     buttonColour:(UIColor *)buttonColour
                       textColour:(UIColor *)textColour;

@end




