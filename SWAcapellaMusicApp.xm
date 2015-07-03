
#import <Social/Social.h>

#import "libSluthware.h"
#import "NSTimer+SW.h"
#import "AcapellaKit.h"
#import "SWAcapellaPrefsBridge.h"
#import "SWAcapellaActionsHelper.h"

#import <MediaRemote/MediaRemote.h>

#import "MusicNowPlayingViewController.h"
#import "MPPlaybackControlsView.h"
#import "MusicNowPlayingPlaybackControlsView.h"
#import "MPAVController.h"
#import "MPAVItem.h"
#import "MPDetailSlider.h"
#import "MPVolumeSlider.h"

#import "substrate.h"
#import <objc/runtime.h>





#pragma mark - MusicNowPlayingViewController

static SWAcapellaBase *_acapella;
//
//static NSDictionary *_previousNowPlayingInfo;





//MPUFoundation.framework

@interface MPUPinningView : UIView
{
    UIView *_containerView;
    UIView *_contentView;
    CALayer *_effectivePinningSourceLayer;
    CALayer *_pinningSourceLayer;
    UIView *_pinningSourceView;
}

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic) UIView *contentView;
@property (nonatomic) CALayer *pinningSourceLayer;
@property (nonatomic) UIView *pinningSourceView;

@end


%hook MPUPinningView

- (id)init
{
    NSLog(@"PAT PINNINING INIT");
    return %orig();
}

- (id)initWithFrame:(CGRect)frame
{
    id x = %orig(frame);
    NSLog(@"PAT PINNINING INIT  %@", x);
    return x;
}

%end




@interface MPUVibrantContentEffectView : UIView
{
}

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic) NSMapTable *layerPinningViewMap; //lower level MPUPinningViews, with their layers descriptions as keys
@property (nonatomic) MPUPinningView *maskedView; //the top level MPUPinningView

- (id)_layersNotWantingVibrancyForSubviewsOfView:(id)view;

- (void)updateEffect;
- (void)updateVibrancyForContentView;

@end











@interface MusicNowPlayingViewController(SW)
{
}

@property (strong, nonatomic) SWAcapellaBase *acapella;

@property (strong, nonatomic) MPUVibrantContentEffectView *vibrantEffectView;

//
//@property (strong, nonatomic) NSDictionary *previousNowPlayingInfo;
//
//- (void)startRatingShouldHideTimer;
//- (void)hideRatingControlWithTimer;

//- (UIView *)mediaControlsView;
//- (MPAVController *)player;
//- (UIView *)progressControl;
//- (UIView *)trackInformationView;
//- (UIView *)transportControls;
//- (UIView *)volumeView;
//- (UIView *)ratingControl;
//- (UIView *)repeatButton;
//- (UIView *)geniusButton;
//- (UIButton *)createButton;
//- (UIView *)shuffleButton;
//- (UIView *)artworkView;
//- (MPAVItem *)mpavItem;
//- (UIButton *)likeOrBanButton;

@end





%hook MusicNowPlayingViewController

//%new
//- (UIView *)mediaControlsView
//{
//    return MSHookIvar<UIView *>(self, "_playbackControlsView");
//}
//
//%new
//- (MPAVController *)player
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<MPAVController *>([self mediaControlsView], "_player");
//}
//
//%new
//- (UIView *)progressControl
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIView *>([self mediaControlsView], "_progressControl");
//}
//
//%new
//- (UIView *)trackInformationView
//{
//    return MSHookIvar<UIView *>(self, "_titlesView");
//}
//
//%new
//- (UIView *)transportControls
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIView *>([self mediaControlsView], "_transportControls");
//}
//
//%new
//- (UIView *)volumeView
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIView *>([self mediaControlsView], "_volumeSlider");
//}
//
//%new
//- (UIView *)ratingControl
//{
//    return MSHookIvar<UIView *>(self, "_ratingControl");
//}
//
//%new
//- (UIView *)repeatButton
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIView *>([self mediaControlsView], "_repeatButton");
//}
//
//%new
//- (UIView *)geniusButton
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIView *>([self mediaControlsView], "_geniusButton");
//}
//
//%new
//- (UIButton *)createButton
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIButton *>([self mediaControlsView], "_createButton");
//}
//
//%new
//- (UIView *)shuffleButton
//{
//    if (![self mediaControlsView]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIView *>([self mediaControlsView], "_shuffleButton");
//}
//
//%new
//- (UIView *)artworkView
//{
//    return MSHookIvar<UIView *>(self, "_contentView");
//}
//
//%new
//- (MPAVItem *)mpavItem
//{
//    return MSHookIvar<MPAVItem *>(self, "_item");
//}
//
//%new
//- (UIButton *)likeOrBanButton
//{
//    if (![self transportControls]){
//        return nil;
//    }
//    
//    return MSHookIvar<UIButton *>([self transportControls], "_likeOrBanButton");
//}



//UIView *x = [self playbackProgressSliderView];
//x = [self titlesView];
//x = [self transportControls];
//x = [self volumeSlider];




%new
- (SWAcapellaBase *)acapella
{
    if (![[SWAcapellaPrefsBridge valueForKey:@"ma_enabled" defaultValue:@YES] boolValue]){
        return nil;
    }
    
    SWAcapellaBase *a = objc_getAssociatedObject(self, &_acapella);
    
    if (!a){
        
        //UIView *mediaControlsView = [self titlesView].superview;
        
        //NSLog(@"PAT 111 %@", mediaControlsView);
        
        //if (mediaControlsView) {
            
            [self setAcapella:[[%c(SWAcapellaBase) alloc] init]];
            a = objc_getAssociatedObject(self, &_acapella);
            a.delegate = self;
            
            
            
            
            
            
            
            
            
            
            
            
            
//            //acapella constraints
//            a.widthConstraint = [NSLayoutConstraint constraintWithItem:a
//                                                                         attribute:NSLayoutAttributeWidth
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:mediaControlsView
//                                                                         attribute:NSLayoutAttributeWidth
//                                                                        multiplier:1.0
//                                                                          constant:0.0];
//            [mediaControlsView addConstraint:a.widthConstraint];
//            
//            a.heightConstraint = [NSLayoutConstraint constraintWithItem:a
//                                                                          attribute:NSLayoutAttributeHeight
//                                                                          relatedBy:NSLayoutRelationEqual
//                                                                             toItem:nil
//                                                                          attribute:NSLayoutAttributeNotAnAttribute
//                                                                         multiplier:1.0
//                                                                           constant:0.0];
//            [mediaControlsView addConstraint:a.heightConstraint];
//            
//            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
//                                                                          attribute:NSLayoutAttributeBottom
//                                                                          relatedBy:NSLayoutRelationEqual
//                                                                             toItem:mediaControlsView
//                                                                          attribute:NSLayoutAttributeBottom
//                                                                         multiplier:1.0
//                                                                           constant:0.0]];
//            [mediaControlsView addConstraint:[NSLayoutConstraint constraintWithItem:a
//                                                                          attribute:NSLayoutAttributeLeading
//                                                                          relatedBy:NSLayoutRelationEqual
//                                                                             toItem:mediaControlsView
//                                                                          attribute:NSLayoutAttributeLeft
//                                                                         multiplier:1.0
//                                                                           constant:0.0]];
        //}
    }
    
    return a;
}

%new
- (void)setAcapella:(SWAcapellaBase *)acapella
{
    objc_setAssociatedObject(self, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//%new
//- (NSDictionary *)previousNowPlayingInfo
//{
//    return objc_getAssociatedObject(self, &_previousNowPlayingInfo);
//}
//
//%new
//- (void)setPreviousNowPlayingInfo:(NSDictionary *)previousNowPlayingInfo
//{
//    objc_setAssociatedObject(self, &_previousNowPlayingInfo, previousNowPlayingInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

#pragma mark - Init

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UIView *parent = [self titlesView].superview;
    
    if (parent && object == parent && !CGRectIsEmpty(parent.bounds)){
        
        NSLog(@"PAT WAS HERE %@", change);
        
        //remove all added contraints
//        for (NSLayoutConstraint *c in self.view.constraints){
//            if (c.firstItem == self.acapella){
//                [parent removeConstraint:c];
//            }
        //        }
        
        //dispatch_async(dispatch_get_main_queue(), ^(void){
            
        self.acapella.frame = [self titlesView].frame;
        NSLog(@"PAT WAS HERE %@-----%@", self.acapella, [self titlesView]);
//        [self.acapella layoutIfNeeded];
//        [self.acapella setNeedsDisplay];
        
        
        
       
        
        
        
        
        
        
//        //create acapella constraints
//        [parent addConstraint:[NSLayoutConstraint constraintWithItem:self.acapella
//                                                        attribute:NSLayoutAttributeWidth
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:parent
//                                                        attribute:NSLayoutAttributeWidth
//                                                       multiplier:1.0
//                                                         constant:0.0]];
//        [parent addConstraint:[NSLayoutConstraint constraintWithItem:self.acapella
//                                                        attribute:NSLayoutAttributeHeight
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:parent
//                                                        attribute:NSLayoutAttributeHeight
//                                                       multiplier:1.0
//                                                         constant:0.0]];
//        [parent addConstraint:[NSLayoutConstraint constraintWithItem:self.acapella
//                                                        attribute:NSLayoutAttributeCenterX
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:parent
//                                                        attribute:NSLayoutAttributeCenterX
//                                                       multiplier:1.0
//                                                         constant:0.0]];
//        [parent addConstraint:[NSLayoutConstraint constraintWithItem:self.acapella
//                                                        attribute:NSLayoutAttributeCenterY
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:parent
//                                                        attribute:NSLayoutAttributeCenterY
//                                                       multiplier:1.0
//                                                         constant:0.0]];
            
//            [self.view layoutIfNeeded];
//            [parent layoutIfNeeded];
//            //[parent setNeedsDisplay];
//            [self.acapella layoutIfNeeded];
            //[self.acapella setNeedsDisplay];
        //});
    }
}

- (void)viewDidLoad
{
    if (self.acapella){}
    self.acapella.frame = CGRectMake(0, 400, 300, 200);
    
    %orig();
    
    //create MPUPinningView pinning
    
    MPUPinningView *pinning = [[%c(MPUPinningView) alloc] init];
    //add Acapella to it
    pinning.contentView = [[UIView alloc] init];
    pinning.pinningSourceLayer = self.acapella.layer;
    
    NSLog(@"INSANE TEST 111 %@", pinning);
    
    //add MPUPinningView to MPUVibrantContentEffectView map
    //add as subview?
    [self.vibrantEffectView addSubview:pinning];
    
//    [self.vibrantEffectView updateEffect];
//    [self.vibrantEffectView updateVibrancyForContentView];
    
    
    NSMapTable *newPinningMap = [[NSMapTable alloc] init];
    
    for (id x in self.vibrantEffectView.layerPinningViewMap.keyEnumerator){
        NSLog(@"%@---%@", x, [self.vibrantEffectView.layerPinningViewMap objectForKey:x]);
        [newPinningMap setObject:[self.vibrantEffectView.layerPinningViewMap objectForKey:x] forKey:x];
    }
    
    [newPinningMap setObject:pinning forKey:pinning.pinningSourceLayer.description];
    
    NSLog(@"\n\n\n\n\n\n\n\n PAT TITS %@", newPinningMap);
    
    self.vibrantEffectView.layerPinningViewMap = newPinningMap;
    
    //NSLog(@"INSANE TEST 111 %@", self.vibrantEffectView.layerPinningViewMap);
    
    //pinning.sourceLayer = acapella.layer
    //return scrollview layer in layersNotWantingVibrancy
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //volume - 14fe62a30
    //volume layer - 1744350e0
    //pinningSourceLayer - 174450e0
    //
    //pinning.containerView - scrubber --- 14fd6c8f0
    //pinning.contentView - scrubber ----- 14fd6ca00
    
    //knob view - 14fe65180
    //knob layer - 17443b560
    
    //layers not wanting vibrancy - 17443b560
    
    
    
    
    //self.acapella
    
    
    //UIView *sex = [self titlesView].superview;
    //[sex addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    //[sex addSubview:self.acapella];
}

//
//- (void)viewWillAppear:(BOOL)arg1
//{
//    %orig(arg1);
//    
//    if (self.acapella){
//        [self.acapella.scrollview resetContentOffset:NO];
//    }
//    
//    MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(mediaRemoteNowPlayingInfoDidChangeNotification)
//                                                 name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
//                                               object:nil];
//}

//- (void)viewDidAppear:(BOOL)arg1
//{
//    %orig(arg1);
//    
//    if (self.acapella){
//        [self.acapella.scrollview resetContentOffset:NO];
//        
//        
//        //TODO: do better
////        MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
////            
////            NSDictionary *resultDict = (__bridge NSDictionary *)result;
////            
////            if (resultDict){
////                
////                BOOL isMusicApp = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoIsMusicApp] boolValue];
////                
////                if (!isMusicApp){ //reset to music app, so thats what we control
////                    if ([self player]){
////                        [[self player] togglePlayback];
////                        [[self player] togglePlayback];
////                    }
////                }
////            }
////        });
//    }
//}

//- (void)viewDidDisappear:(BOOL)arg1
//{
//    %orig(arg1);
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification
//                                                  object:nil];
//    
//    MRMediaRemoteUnregisterForNowPlayingNotifications();
//}
//
//#pragma mark - MediaRemote
//
//%new
//- (void)mediaRemoteNowPlayingInfoDidChangeNotification
//{
//    if (!self.view.window || !self.acapella){
//        return;
//    }
//    
//    if (![NSThread isMainThread]){
//        [self performSelectorOnMainThread:@selector(mediaRemoteNowPlayingInfoDidChangeNotification) withObject:nil waitUntilDone:NO];
//        return;
//    }
//    
//    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
//        
//        NSDictionary *resultDict = (__bridge NSDictionary *)result;
//        
//        if (resultDict){
//            
//            NSNumber *uid = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier];
//            NSNumber *previousUID;
//            
//            if (self.previousNowPlayingInfo){
//                previousUID = [self.previousNowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier];
//            }
//            
//            if (uid){
//                if (!previousUID || (previousUID && ![uid isEqualToNumber:previousUID])){
//                    
//                    [self.acapella.scrollview finishWrapAroundAnimation];
//                    
//                } else {
//                    
//                    NSNumber *elapsedTime = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime];
//                    
//                    if (elapsedTime && [elapsedTime doubleValue] <= 0.0){ //restarted the song
//                        
//                        [self.acapella.scrollview finishWrapAroundAnimation];
//                        
//                    }
//                }
//            } else {
//                
//                [self.acapella.scrollview finishWrapAroundAnimation];
//                
//            }
//        }
//        
//        self.previousNowPlayingInfo = resultDict;
//        
//    });
//}
//
//#pragma mark - SWAcapellaDelegate
//
//%new
//- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
//{
//    if (tap.state == UIGestureRecognizerStateEnded){
//        
//        swAcapellaAction action;
//        
//        CGFloat percentBoundaries = 0.2;
//        
//        if (percentage.x <= percentBoundaries){ //left
//            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                               valueForKey:@"leftTapAction" defaultValue:@7]
//                                                 withDelegate:self];
//        } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
//            
//            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                               valueForKey:@"centreTapAction" defaultValue:@1]
//                                                 withDelegate:self];
//            
//        } else if (percentage.x > (1.0 - percentBoundaries)){ //right
//            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                               valueForKey:@"rightTapAction" defaultValue:@8]
//                                                 withDelegate:self];
//        }
//        
//        if (action){
//            action();
//        }
//        
//    }
//}
//
//%new
//- (void)swAcapella:(SWAcapellaBase *)swAcapella onSwipe:(UISwipeGestureRecognizerDirection)direction
//{
//    swAcapellaAction action;
//    
//    [self.acapella.scrollview stopWrapAroundFallback];
//    
//    if (direction == UISwipeGestureRecognizerDirectionLeft){
//        
//        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:@"swipeLeftAction" defaultValue:@3]
//                                             withDelegate:self];
//        
//    } else if (direction == UISwipeGestureRecognizerDirectionRight){
//        
//        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge valueForKey:@"swipeRightAction" defaultValue:@2]
//                                             withDelegate:self];
//        
//    } else if (direction == UISwipeGestureRecognizerDirectionUp) {
//        
//        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                           valueForKey:@"swipeUpAction" defaultValue:@0]
//                                             withDelegate:self];
//        
//    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
//        
//        action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                           valueForKey:@"swipeDownAction" defaultValue:@0]
//                                             withDelegate:self];
//        
//    }
//    
//    if (action){
//        action();
//    } else {
//        [self.acapella.scrollview finishWrapAroundAnimation];
//    }
//}
//
//%new
//- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
//{
//    CGFloat percentBoundaries = 0.2;
//    
//    swAcapellaAction action;
//    
//    if (percentage.x <= percentBoundaries){ //left
//        
//        if (longPress.state == UIGestureRecognizerStateBegan){
//            
//            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                               valueForKey:@"leftPressAction" defaultValue:@4]
//                                                 withDelegate:self];
//            
//        }
//        
//    } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
//        
//        if (longPress.state == UIGestureRecognizerStateBegan){
//            
//            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                               valueForKey:@"centrePressAction" defaultValue:@6]
//                                                 withDelegate:self];
//            
//        }
//        
//    } else if (percentage.x > (1.0 - percentBoundaries)){ //right
//        
//        if (longPress.state == UIGestureRecognizerStateBegan){
//            
//            action = [SWAcapellaActionsHelper methodForAction:[SWAcapellaPrefsBridge
//                                                               valueForKey:@"rightPressAction" defaultValue:@5]
//                                                 withDelegate:self];
//            
//        }
//        
//    }
//    
//    if (action){
//        action();
//    }
//}
//
//%new
//- (void)swAcapella:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    UIView *mediaControlsView = [self mediaControlsView];
//    
//    if (mediaControlsView){
//        
//        if (indexPath.section == 0){
//            switch (indexPath.row){
//                case 0:
//                    
//                    if ([self volumeView].superview){
//                        [[self volumeView] removeFromSuperview];
//                    }
//                    
//                    if ([self progressControl]){
//                        [cell addSubview:[self progressControl]];
//                    }
//                    
//                    break;
//                    
//                case 1:
//                    
//                    if ([self trackInformationView] && view.scrollview){
//                        [view.scrollview addSubview:[self trackInformationView]];
//                        [self trackInformationView].frame = [self trackInformationView].frame;
//                    }
//                    
//                    break;
//                    
//                case 2:
//                    
//                    if ([self progressControl].superview){
//                        [[self progressControl] removeFromSuperview];
//                    }
//                    
//                    if ([self volumeView]){
//                        [cell addSubview:[self volumeView]];
//                    }
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
//        
//        [mediaControlsView layoutSubviews];
//        
//    }
//}
//
//#pragma mark - Actions
//
//%new
//- (void)action_PlayPause
//{
//    [SWAcapellaActionsHelper action_PlayPause:^(BOOL successful, id object){
//        if (successful && self.acapella){
//            [UIView animateWithDuration:0.1
//                             animations:^{
//                                 self.acapella.transform = CGAffineTransformMakeScale(0.9, 0.9);
//                             } completion:^(BOOL finished){
//                                 [UIView animateWithDuration:0.1
//                                                  animations:^{
//                                                      self.acapella.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                                  } completion:^(BOOL finished){
//                                                      self.acapella.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                                  }];
//                             }];
//        }
//    }];
//}
//
//%new
//- (void)action_PreviousSong
//{
//    [SWAcapellaActionsHelper action_PreviousSong:^(BOOL successful, id object){
//        [SWAcapellaActionsHelper isCurrentItemRadioItem:^(BOOL successful, id object){
//            if (successful){
//                
//                [self.acapella.scrollview finishWrapAroundAnimation]; //make sure we wrap around on iTunes Radio
//                
//            } else {
//                
//                MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul),
//                                               ^(CFDictionaryRef result){
//                                                   
//                                                   NSDictionary *resultDict = (__bridge NSDictionary *)result;
//                                                   
//                                                   if (resultDict){
//                                                       
//                                                       double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
//                                                       
//                                                       if (mediaCurrentElapsedDuration >= 2.0 || mediaCurrentElapsedDuration <= 0.0){
//                                                           
//                                                           [self.acapella.scrollview finishWrapAroundAnimation];
//                                                       }
//                                                   }
//                                               });
//            }
//        }];
//    }];
//}
//
//%new
//- (void)action_NextSong
//{
//    [SWAcapellaActionsHelper action_NextSong:^(BOOL successful, id object){
//    }];
//}
//
//%new
//- (void)action_SkipBackward
//{
//    [SWAcapellaActionsHelper action_SkipBackward];
//}
//
//%new
//- (void)action_SkipForward
//{
//    [SWAcapellaActionsHelper action_SkipForward];
//}
//
//%new
//- (void)action_ShowRatings
//{
//    
//}
//
//%new
//- (void)action_DecreaseVolume
//{
//    [SWAcapellaActionsHelper action_DecreaseVolume];
//}
//
//%new
//- (void)action_IncreaseVolume
//{
//    [SWAcapellaActionsHelper action_IncreaseVolume];
//}
//
//#pragma mark - Rating
//
//static BOOL _didTouchRatingControl = NO;
//static NSTimer *_hideRatingTimer;
//
//- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2
//{
//    %orig(arg1, arg2);
//    
//    if (self.acapella){
//        
//        if (arg1){
//            [self startRatingShouldHideTimer];
//            self.acapella.userInteractionEnabled = NO;
//        } else {
//            if (_hideRatingTimer){
//                [_hideRatingTimer invalidate];
//                _hideRatingTimer = nil;
//            }
//            self.acapella.userInteractionEnabled = YES;
//        }
//    }
//}
//
//%new
//- (void)startRatingShouldHideTimer
//{
//    BOOL isShowingRating = MSHookIvar<BOOL>(self, "_isShowingRatings");
//    
//    if (_hideRatingTimer){
//        [_hideRatingTimer invalidate];
//        _hideRatingTimer = nil;
//    }
//    
//    if (!isShowingRating){
//        return;
//    }
//    
//    _hideRatingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
//                                                        target:self
//                                                      selector:@selector(hideRatingControlWithTimer)
//                                                      userInfo:nil
//                                                       repeats:NO];
//}
//
//%new
//- (void)hideRatingControlWithTimer
//{
//    BOOL isShowingRating = MSHookIvar<BOOL>(self, "_isShowingRatings");
//    
//    if (!isShowingRating){
//        _didTouchRatingControl = NO;
//        return;
//    }
//    
//    if (_didTouchRatingControl){
//        _didTouchRatingControl = NO;
//        [self startRatingShouldHideTimer];
//        return;
//    }
//    
//    [self _setShowingRatings:NO animated:YES];
//    _didTouchRatingControl = NO;
//}
//
//%end





#pragma mark - MPURatingControl

//%hook MPURatingControl //keep track of touches and delay our hide timer
//
//- (void)_handlePanGesture:(id)arg1
//{
//    %orig(arg1);
//    
//    _didTouchRatingControl = YES;
//}
//
//- (void)_handleTapGesture:(id)arg1
//{
//    %orig(arg1);
//    
//    _didTouchRatingControl = YES;
//}
//
%end





#pragma mark - MPPlaybackControlsView

//static void mpPlaybackControlsPostLayout(UIView *mpu)
//{
//    SWAcapellaBase *acapella;
//    
//    for (UIView *v in mpu.subviews){
//        if ([v isKindOfClass:%c(SWAcapellaBase)]){
//            acapella = (SWAcapellaBase *)v;
//        }
//    }
//    
//    //if acapella is not nil, then we know it is enabled
//    if (acapella){
//        
//        //UIView *time = MSHookIvar<UIView *>(mpu, "_progressControl");
//        UIView *titles = MSHookIvar<UIView *>(mpu, "_titlesView");
//        UIView *transport = MSHookIvar<UIView *>(mpu, "_transportControls");
//        //UIView *volume = MSHookIvar<UIView *>(mpu, "_volumeSlider");
//        
//        if (titles){
//            [acapella.scrollview addSubview:titles];
//            titles.frame = titles.frame; //center
//        }
//        
//        if (transport){
//            transport.center = CGPointMake(6900, transport.center.y);
//        }
//        
//    }
//}

%hook MusicNowPlayingPlaybackControlsView

//- (void)layoutIfNeeded
//{
//    %orig();
//    mpPlaybackControlsPostLayout(self);
//}
//
//- (void)layoutSubviews
//{
//    %orig();
//    mpPlaybackControlsPostLayout(self);
//}

%end





#pragma mark - logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}




