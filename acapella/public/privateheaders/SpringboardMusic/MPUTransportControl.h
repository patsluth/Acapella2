
@interface MPUTransportControl : NSObject <NSCopying>
{
    BOOL _enabled;
}

@property(getter=isEnabled) BOOL enabled;

+ (id)availableTransportControlsForMediaRemoteCommands:(struct __CFArray { }*)arg1 controlsCount:(unsigned int)arg2;

- (BOOL)isEnabled;

@end




