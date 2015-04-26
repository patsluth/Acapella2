
#import "SWAcapellaSharingFormatter.h"

#import <UIKit/UIKit.h>

@implementation SWAcapellaSharingFormatter

+ (NSArray *)formattedShareArrayWithMediaTitle:(NSString *)title
                                    mediaArtist:(NSString *)artist
                              mediaArtworkData:(NSData *)data
                                sharingHashtag:(NSString *)hashtag
{
    if (!title){
        return nil;
    }
    
    NSMutableString *shareString = [[NSMutableString alloc] init];
    
    [shareString appendString:title];
    
    if (artist && ![artist isEqualToString:@""]){
        [shareString appendString:@" by "];
        [shareString appendString:artist];
    }
    
    if (hashtag && ![hashtag isEqualToString:@""]){
        [shareString appendString:@" #"];
        [shareString appendString:hashtag];
    }
    
    if (data && [data length] != 0){
	    return @[shareString, [[UIImage alloc] initWithData:data]];
    } else {
	    return @[shareString];
    }
}

@end




