
#import <libsw/sluthwareios/sluthwareios.h>

@interface SWAcapellaActivityViewController : UIActivityViewController

- (id)initWithSongTitle:(NSString *)songTitle
                 artist:(NSString *)artist
                  album:(NSString *)album
                artwork:(UIImage *)artwork
         sharingHashtag:(NSString *)sharingHashtag;

@end




