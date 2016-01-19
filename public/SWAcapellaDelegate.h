//
//  SWAcapellaDelegate.h
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-25.
//
//

#ifndef SWAcapellaDelegate_h
#define SWAcapellaDelegate_h

@class SWAcapella, SWAcapellaPrefs;





@protocol SWAcapellaDelegate <NSObject, UIViewControllerPreviewingDelegate>

@required

@property (strong, nonatomic) NSString *acapellaKeyPrefix;
@property (strong, nonatomic) SWAcapellaPrefs *acapellaPrefs;

- (SWAcapella *)acapella;

- (void)action_heart:(id)arg1;
- (void)action_upnext:(id)arg1;
- (void)action_previoustrack:(id)arg1;
- (void)action_nexttrack:(id)arg1;
- (void)action_intervalrewind:(id)arg1;
- (void)action_intervalforward:(id)arg1;
- (void)action_seekrewind:(id)arg1;
- (void)action_seekforward:(id)arg1;
- (void)action_playpause:(id)arg1;
- (void)action_share:(id)arg1;
- (void)action_toggleshuffle:(id)arg1;
- (void)action_togglerepeat:(id)arg1;
- (void)action_contextual:(id)arg1;
- (void)action_openapp:(id)arg1;
- (void)action_showratings:(id)arg1;
- (void)action_decreasevolume:(id)arg1;
- (void)action_increasevolume:(id)arg1;
- (void)action_equalizereverywhere:(id)arg1;

@end

#endif /* SWAcapellaDelegate_h */




