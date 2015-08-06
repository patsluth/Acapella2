




@interface SWAcapellaPrefsBridge : NSObject
{
}

+ (NSDictionary *)preferences;

+ (id)valueForKey:(NSString *)key defaultValue:(id)defaultValue;

@end




