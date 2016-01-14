//
//  SWAcapellaPrefs.h
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//





@interface SWAcapellaPrefs : NSObject
{
}


@property (strong, nonatomic, readonly) NSString *application;
@property (strong, nonatomic, readonly) NSString *keyPrefix;

// In same order as the preference pane layout :P
@property (nonatomic, readonly) BOOL enabled;
// Gestures
@property (strong, nonatomic, readonly) NSString *gestures_tapleft;
@property (strong, nonatomic, readonly) NSString *gestures_tapcentre;
@property (strong, nonatomic, readonly) NSString *gestures_tapright;
@property (strong, nonatomic, readonly) NSString *gestures_swipeleft;
@property (strong, nonatomic, readonly) NSString *gestures_swiperight;
@property (strong, nonatomic, readonly) NSString *gestures_popactionleft;
@property (strong, nonatomic, readonly) NSString *gestures_popactioncentre;
@property (strong, nonatomic, readonly) NSString *gestures_popactionright;
// UI(Progress Slider)
@property (nonatomic, readonly) BOOL progressslider;
// UI(Transport)
@property (nonatomic, readonly) BOOL transport_heart;
@property (nonatomic, readonly) BOOL transport_upnext;
@property (nonatomic, readonly) BOOL transport_previoustrack;
@property (nonatomic, readonly) BOOL transport_nexttrack;
@property (nonatomic, readonly) BOOL transport_intervalrewind;
@property (nonatomic, readonly) BOOL transport_intervalforward;
@property (nonatomic, readonly) BOOL transport_playpause;
@property (nonatomic, readonly) BOOL transport_share;
@property (nonatomic, readonly) BOOL transport_shuffle;
@property (nonatomic, readonly) BOOL transport_repeat;
@property (nonatomic, readonly) BOOL transport_contextual;
// UI(Volume Slider)
@property (nonatomic, readonly) BOOL volumeslider;


- (id)initWithApplication:(NSString *)application keyPrefix:(NSString *)keyPrefix;

- (void)refreshPrefs;

@end




