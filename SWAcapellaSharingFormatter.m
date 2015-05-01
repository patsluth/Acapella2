
#import "SWAcapellaSharingFormatter.h"

#import <UIKit/UIKit.h>

@implementation SWAcapellaSharingFormatter

+ (NSDictionary *)formattedShareDictionaryWithMediaTitle:(NSString *)title
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
    
    NSMutableDictionary *shareDictionary = [[NSMutableDictionary alloc] init];
    [shareDictionary setValue:shareString forKey:@"shareString"];
    
    if (data && [data length] != 0){
        [shareDictionary setValue:[[UIImage alloc] initWithData:data] forKey:@"shareImage"];
    }
    
    return shareDictionary;
}

@end



