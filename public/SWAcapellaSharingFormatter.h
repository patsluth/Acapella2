
@interface SWAcapellaSharingFormatter : NSObject

+ (NSArray *)formattedShareArrayWithMediaTitle:(NSString *)title
                                   mediaArtist:(NSString *)artist
                              mediaArtworkData:(NSData *)data
                                sharingHashtag:(NSString *)hashtag;

@end




