//
//  SWAcapellaPrefs.m
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapellaPrefs.h"

#define PREFS_DEFAULTS_PATH @"/Library/PreferenceBundles/AcapellaPrefs2.bundle"





@interface SWAcapellaPrefs()
{
}

@property (strong, nonatomic, readwrite) NSString *application;
@property (strong, nonatomic, readwrite) NSString *keyPrefix;

// In same order as the preference pane layout :P
@property (nonatomic, readwrite) BOOL enabled;
// Gestures
@property (strong, nonatomic, readwrite) NSString *gestures_tapleft;
@property (strong, nonatomic, readwrite) NSString *gestures_tapcentre;
@property (strong, nonatomic, readwrite) NSString *gestures_tapright;
@property (strong, nonatomic, readwrite) NSString *gestures_swipeleft;
@property (strong, nonatomic, readwrite) NSString *gestures_swiperight;
@property (strong, nonatomic, readwrite) NSString *gestures_popactionleft;
@property (strong, nonatomic, readwrite) NSString *gestures_popactioncentre;
@property (strong, nonatomic, readwrite) NSString *gestures_popactionright;
// UI(Progress Slider)
@property (nonatomic, readwrite) BOOL progressslider;
// UI(Transport)
@property (nonatomic, readwrite) BOOL transport_heart;
@property (nonatomic, readwrite) BOOL transport_upnext;
@property (nonatomic, readwrite) BOOL transport_previoustrack;
@property (nonatomic, readwrite) BOOL transport_nexttrack;
@property (nonatomic, readwrite) BOOL transport_intervalrewind;
@property (nonatomic, readwrite) BOOL transport_intervalforward;
@property (nonatomic, readwrite) BOOL transport_playpause;
@property (nonatomic, readwrite) BOOL transport_share;
@property (nonatomic, readwrite) BOOL transport_shuffle;
@property (nonatomic, readwrite) BOOL transport_repeat;
@property (nonatomic, readwrite) BOOL transport_contextual;
// UI(Volume Slider)
@property (nonatomic, readwrite) BOOL volumeslider;

@end





@implementation SWAcapellaPrefs

- (id)initWithApplication:(NSString *)application keyPrefix:(NSString *)keyPrefix
{
    self = [super init];
    
    if (self) {
        
        [self initialize];
        
        self.application = application;
        self.keyPrefix = keyPrefix;
        
        [self refreshPrefs];
        
    }
    
    return self;
}

/**
 *  Initialize to defaults
 */
- (void)initialize
{
    self.enabled = NO;
    // Gestures
    self.gestures_tapleft = @"";
    self.gestures_tapcentre = @"";
    self.gestures_tapright = @"";
    self.gestures_swipeleft = @"";
    self.gestures_swiperight = @"";
    self.gestures_popactionleft = @"";
    self.gestures_popactioncentre = @"";
    self.gestures_popactionright = @"";
    // UI(Progress Slider)
    self.progressslider = YES;
    // UI(Transport)
    self.transport_heart = YES;
    self.transport_upnext = YES;
    self.transport_previoustrack = YES;
    self.transport_nexttrack = YES;
    self.transport_intervalrewind = YES;
    self.transport_intervalforward = YES;
    self.transport_playpause = YES;
    self.transport_share = YES;
    self.transport_shuffle = YES;
    self.transport_repeat = YES;
    self.transport_contextual = YES;
    // UI(Volume Slider)
    self.volumeslider = YES;
}

- (void)refreshPrefs
{
    // *********************
    // INITIALIZE KEYS
    // *********************
    
    NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"enabled"];
    // Gestures
    NSString *gestures_tapleftKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_tapleft"];
    NSString *gestures_tapcentreKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_tapcentre"];
    NSString *gestures_taprightKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_tapright"];
    NSString *gestures_swipeleftKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_swipeleft"];
    NSString *gestures_swiperightKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_swiperight"];
    NSString *gestures_popactionleftKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_popactionleft"];
    NSString *gestures_popactioncentreKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_popactioncentre"];
    NSString *gestures_popactionrightKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"gestures_popactionright"];
    // UI(Progress Slider)
    NSString *progresssliderKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"progressslider"];
    // UI(Transport)
    NSString *transport_heartKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_heart"];
    NSString *transport_upnextKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_upnext"];
    NSString *transport_previoustrackKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_previoustrack"];
    NSString *transport_nexttrackKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_nexttrack"];
    NSString *transport_intervalrewindKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_intervalrewind"];
    NSString *transport_intervalforwardKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_intervalforward"];
    NSString *transport_playpauseKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_playpause"];
    NSString *transport_shareKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_share"];
    NSString *transport_shuffleKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_shuffle"];
    NSString *transport_repeatKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_repeat"];
    NSString *transport_contextualKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"transport_contextual"];
    // UI(Volume Slider)
    NSString *volumesliderKey = [NSString stringWithFormat:@"%@_%@", self.keyPrefix, @"volumeslider"];
    
    
    
    
    
    // *********************
    // LOAD VALUES FROM KEYS
    // *********************
    CFStringRef applicationCF = (__bridge CFStringRef)self.application;
    
    [self getAppBooleanForKey:enabledKey output:&self->_enabled];
    // Gestures
    self.gestures_tapleft = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_tapleftKey, applicationCF));
    self.gestures_tapcentre = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_tapcentreKey, applicationCF));
    self.gestures_tapright = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_taprightKey, applicationCF));
    self.gestures_swipeleft = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_swipeleftKey, applicationCF));
    self.gestures_swiperight = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_swiperightKey, applicationCF));
    self.gestures_popactionleft = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_popactionleftKey, applicationCF));
    self.gestures_popactioncentre = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_popactioncentreKey, applicationCF));
    self.gestures_popactionright = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_popactionrightKey, applicationCF));
    // UI(Progress Slider)
    [self getAppBooleanForKey:progresssliderKey output:&self->_progressslider];
    // UI(Transport)
    [self getAppBooleanForKey:transport_heartKey output:&self->_transport_heart];
    [self getAppBooleanForKey:transport_upnextKey output:&self->_transport_upnext];
    [self getAppBooleanForKey:transport_intervalrewindKey output:&self->_transport_previoustrack];
    [self getAppBooleanForKey:transport_intervalforwardKey output:&self->_transport_nexttrack];
    [self getAppBooleanForKey:transport_previoustrackKey output:&self->_transport_intervalrewind];
    [self getAppBooleanForKey:transport_nexttrackKey output:&self->_transport_intervalforward];
    [self getAppBooleanForKey:transport_playpauseKey output:&self->_transport_playpause];
    [self getAppBooleanForKey:transport_shareKey output:&self->_transport_share];
    [self getAppBooleanForKey:transport_shuffleKey output:&self->_transport_shuffle];
    [self getAppBooleanForKey:transport_repeatKey output:&self->_transport_repeat];
    [self getAppBooleanForKey:transport_contextualKey output:&self->_transport_contextual];
    // UI(Volume Slider)
    [self getAppBooleanForKey:volumesliderKey output:&self->_volumeslider];
    
}

/**
 *  Helper method to get BOOL pref value if key exists. Will remain as default value if key does not exist
 */
- (void)getAppBooleanForKey:(NSString *)key output:(inout BOOL *)output
{
    Boolean keyExistsAndHasValidFormat = NO;
    
    BOOL value = (BOOL)CFPreferencesGetAppBooleanValue((__bridge CFStringRef)key,
                                                       (__bridge CFStringRef)self.application,
                                                       &keyExistsAndHasValidFormat);
    
    if (keyExistsAndHasValidFormat) {
        *output = value;
    }
}

@end






%ctor //syncronize acapella default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:PREFS_DEFAULTS_PATH];
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"prefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefsDefaults) {
        
        CFStringRef application = [key containsString:@"music"] ? CFSTR("com.apple.Music") : CFSTR("com.patsluth.AcapellaPrefs2");
        
        id currentValue = (id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, application));
        
        if (currentValue == nil) { //dont overwrite
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                     application);
            
        }
        
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.AcapellaPrefs2"));
    CFPreferencesAppSynchronize(CFSTR("com.apple.Music"));
    
}




