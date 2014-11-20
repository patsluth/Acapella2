
#import "SWAcapellaActivityViewController.h"

@interface SWAcapellaActivityViewController()
{
}

//@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation SWAcapellaActivityViewController

- (id)initWithSongTitle:(NSString *)songTitle
                 artist:(NSString *)artist
                  album:(NSString *)album
                artwork:(UIImage *)artwork
         sharingHashtag:(NSString *)sharingHashtag
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if (songTitle){
        [items addObject:songTitle];
    }
    if (artist){
        [items addObject:artist];
    }
    if (album){
        [items addObject:album];
    }
    if (artwork){
        [items addObject:artwork];
    }
    if (sharingHashtag){
        [items addObject:sharingHashtag];
    }
    
    //self = [super initWithActivityItems:items applicationActivities:nil];
    
    if (self){
//        self.excludedActivityTypes = @[UIActivityTypeAssignToContact,
//                                       UIActivityTypePrint,
//                                       //UIActivityTypeCopyToPasteboard,
//                                       UIActivityTypeSaveToCameraRoll];
    }
    
    return self;
}

//- (NSMutableArray *)items
//{
//    if (_items){
//        _items = [[NSMutableArray alloc] init];
//    }
//    
//    return _items;
//}

@end




