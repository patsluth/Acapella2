//
//  SWAcapellaPrefs.m
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapellaPrefs.h"





@interface SWAcapellaPrefs()
{
}

#pragma mark -

@property (strong, nonatomic, readwrite) NSString *keyPrefix;

// In same order as the preference pane layout :P
@property (nonatomic, readwrite) BOOL enabled;

#pragma mark Gestures

@property (strong, nonatomic, readwrite) NSString *gestures_tapleft;
@property (strong, nonatomic, readwrite) NSString *gestures_tapcentre;
@property (strong, nonatomic, readwrite) NSString *gestures_tapright;
@property (strong, nonatomic, readwrite) NSString *gestures_swipeleft;
@property (strong, nonatomic, readwrite) NSString *gestures_swiperight;
@property (strong, nonatomic, readwrite) NSString *gestures_pressleft;
@property (strong, nonatomic, readwrite) NSString *gestures_presscentre;
@property (strong, nonatomic, readwrite) NSString *gestures_pressright;
//@property (strong, nonatomic, readwrite) NSString *gestures_popactionleft;
//@property (strong, nonatomic, readwrite) NSString *gestures_popactioncentre;
//@property (strong, nonatomic, readwrite) NSString *gestures_popactionright;

#pragma mark UI(Progress Slider)

@property (nonatomic, readwrite) BOOL progressslider;

#pragma mark UI(Transport)

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
@property (nonatomic, readwrite) BOOL transport_playbackrate; // podcast
@property (nonatomic, readwrite) BOOL transport_sleeptimer; // podcast

#pragma mark UI(Volume Slider)

@property (nonatomic, readwrite) BOOL volumeslider;

#pragma mark -

@end





@implementation SWAcapellaPrefs

#pragma mark - Init

- (id)initWithKeyPrefix:(NSString *)keyPrefix
{
    self = [super init];
    
    if (self) {
        
        [self initialize];
        
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
#pragma mark -
    
    self.enabled = NO;
    
#pragma mark Gestures
    
    self.gestures_tapleft = @"";
    self.gestures_tapcentre = @"";
    self.gestures_tapright = @"";
    self.gestures_swipeleft = @"";
    self.gestures_swiperight = @"";
    self.gestures_pressleft = @"";
    self.gestures_presscentre = @"";
    self.gestures_pressright = @"";
//    self.gestures_popactionleft = @"";
//    self.gestures_popactioncentre = @"";
//    self.gestures_popactionright = @"";
    
#pragma mark UI(Progress Slider)
    
    self.progressslider = YES;
    
#pragma mark UI(Transport)
    
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
    
#pragma mark UI(Volume Slider)
    
    self.volumeslider = YES;
    
#pragma mark -
    
}

- (void)refreshPrefs
{
    #pragma mark - Initialize Keys
    
    NSString *enabledKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"enabled"];
    
    #pragma mark Gestures
    
    NSString *gestures_tapleftKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_tapleft"];
    NSString *gestures_tapcentreKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_tapcentre"];
    NSString *gestures_taprightKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_tapright"];
    NSString *gestures_swipeleftKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_swipeleft"];
    NSString *gestures_swiperightKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_swiperight"];
    NSString *gestures_pressleftKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_pressleft"];
    NSString *gestures_presscentreKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_presscentre"];
    NSString *gestures_pressrightKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_pressright"];
//    NSString *gestures_popactionleftKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_popactionleft"];
//    NSString *gestures_popactioncentreKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_popactioncentre"];
//    NSString *gestures_popactionrightKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"gestures_popactionright"];
    
    #pragma mark UI(Progress Slider)
    
    NSString *progresssliderKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"progressslider"];
    
    #pragma mark UI(Transport)
    
    NSString *transport_heartKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_heart"];
    NSString *transport_upnextKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_upnext"];
    NSString *transport_previoustrackKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_previoustrack"];
    NSString *transport_nexttrackKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_nexttrack"];
    NSString *transport_intervalrewindKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_intervalrewind"];
    NSString *transport_intervalforwardKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_intervalforward"];
    NSString *transport_playpauseKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_playpause"];
    NSString *transport_shareKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_share"];
    NSString *transport_shuffleKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_shuffle"];
    NSString *transport_repeatKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_repeat"];
    NSString *transport_contextualKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_contextual"];
    NSString *transport_playbackrateKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_playbackrate"];
    NSString *transport_sleeptimerKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"transport_sleeptimer"];
    
    #pragma mark UI(Volume Slider)
    
    NSString *volumesliderKey = [NSString stringWithFormat:@"acapella2_%@_%@", self.keyPrefix, @"volumeslider"];
    
    
    
    
    
    #pragma mark - Load Values For Keys
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.patsluth.acapella2.plist"];
    
    self.enabled = [[prefs valueForKey:enabledKey] boolValue];
    
    #pragma mark Gestures
    
    self.gestures_tapleft = [prefs valueForKey:gestures_tapleftKey];
    self.gestures_tapcentre = [prefs valueForKey:gestures_tapcentreKey];
    self.gestures_tapright = [prefs valueForKey:gestures_taprightKey];
    self.gestures_swipeleft = [prefs valueForKey:gestures_swipeleftKey];
    self.gestures_swiperight = [prefs valueForKey:gestures_swiperightKey];
    self.gestures_pressleft = [prefs valueForKey:gestures_pressleftKey];
    self.gestures_presscentre = [prefs valueForKey:gestures_presscentreKey];
    self.gestures_pressright = [prefs valueForKey:gestures_pressrightKey];
    //    self.gestures_popactionleft = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_popactionleftKey, applicationCF));
    //    self.gestures_popactioncentre = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_popactioncentreKey, applicationCF));
    //    self.gestures_popactionright = CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)gestures_popactionrightKey, applicationCF));
    
    #pragma mark UI(Progress Slider)
    
    self.progressslider = [[prefs valueForKey:progresssliderKey] boolValue];
    
    #pragma mark UI(Transport)
    
    self.transport_heart = [[prefs valueForKey:transport_heartKey] boolValue];
    self.transport_upnext = [[prefs valueForKey:transport_upnextKey] boolValue];
    self.transport_previoustrack = [[prefs valueForKey:transport_previoustrackKey] boolValue];
    self.transport_nexttrack = [[prefs valueForKey:transport_nexttrackKey] boolValue];
    self.transport_intervalrewind = [[prefs valueForKey:transport_intervalrewindKey] boolValue];
    self.transport_intervalforward = [[prefs valueForKey:transport_intervalforwardKey] boolValue];
    self.transport_playpause = [[prefs valueForKey:transport_playpauseKey] boolValue];
    self.transport_share = [[prefs valueForKey:transport_shareKey] boolValue];
    self.transport_shuffle = [[prefs valueForKey:transport_shuffleKey] boolValue];
    self.transport_repeat = [[prefs valueForKey:transport_repeatKey] boolValue];
    self.transport_contextual = [[prefs valueForKey:transport_contextualKey] boolValue];
    self.transport_playbackrate = [[prefs valueForKey:transport_playbackrateKey] boolValue];
    self.transport_sleeptimer = [[prefs valueForKey:transport_sleeptimerKey] boolValue];
    
    #pragma mark UI(Volume Slider)
    
    self.volumeslider = [[prefs valueForKey:volumesliderKey] boolValue];
    
    #pragma mark -
    
}

@end





#pragma mark -  Logos

%ctor //syncronize acapella default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AcapellaPrefs2.bundle"];
    
    NSString *prefsDefaultsPath = [bundle pathForResource:@"prefsDefaults" ofType:@".plist"];
    NSString *prefsPath = @"/User/Library/Preferences/com.patsluth.acapella2.plist";
    
    NSDictionary *prefsDefaults = [NSDictionary dictionaryWithContentsOfFile:prefsDefaultsPath];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    
    for (NSString *key in prefsDefaults) {
        
        if ([prefs valueForKey:key] == nil) { // update value, dont overwrite
            
            [prefs setValue:[prefsDefaults valueForKey:key] forKey:key];
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefsDefaults valueForKey:key],
                                     CFSTR("com.patsluth.acapella2"));
            
        }
        
    }
    
    // syncronize so we can read right away
    [prefs writeToFile:prefsPath atomically:NO];
    CFPreferencesAppSynchronize(CFSTR("com.patsluth.acapella2"));
}




