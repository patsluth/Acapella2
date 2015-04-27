
@interface SWAcapellaSharingFormatter : NSObject

/**
 *  Dictionary of objects to share
 *
 *  @param title   NSString
 *  @param artist  NSString
 *  @param data    NSData
 *  @param hashtag NSString
 *
 *  @return NSDictionary with keys "shareString" "shareImage"
 */
+ (NSDictionary *)formattedShareDictionaryWithMediaTitle:(NSString *)title
                                             mediaArtist:(NSString *)artist
                                        mediaArtworkData:(NSData *)data
                                          sharingHashtag:(NSString *)hashtag;

@end




