

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import <libsw/SWAppLauncher.h>

#import "MPUSystemMediaControlsViewController.h"
#import "_MPUSystemMediaControlsView.h" //iOS 7
#import "MPUSystemMediaControlsView.h" //iOS 8
#import "MPUNowPlayingController.h"
#import "SBCCMediaControlsSectionController.h"
#import "SBMediaController.h"
#import "AVSystemController+SW.h"

#import "substrate.h"
#import <objc/runtime.h>

#import <Springboard/Springboard.h>





#pragma mark MPUSystemMediaControlsViewController

static SWAcapellaBase *_acapella;

%hook MPUSystemMediaControlsViewController

#pragma mark Helper

%new
- (UIView *)mediaControlsView
{
    return MSHookIvar<UIView *>(self, "_mediaControlsView");
}

%new
- (UIView *)timeInformationView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_timeInformationView");
}

%new
- (UIView *)trackInformationView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_trackInformationView");
}

%new
- (UIView *)transportControlsView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_transportControlsView");
}

%new
- (UIView *)volumeView
{
    return MSHookIvar<UIView *>([self mediaControlsView], "_volumeView");
}

%new
- (SWAcapellaBase *)acapella
{
    return objc_getAssociatedObject(self, &_acapella);
}

%new
- (void)setAcapella:(SWAcapellaBase *)acapella
{
    objc_setAssociatedObject(self, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Init

- (void)viewDidLoad
{
    %orig();
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");
    
    if (mediaControlsView){
        
        if ([self timeInformationView].superview == mediaControlsView){
            [[self timeInformationView] removeFromSuperview];
        }
        if ([self trackInformationView].superview == mediaControlsView){
            [[self trackInformationView] removeFromSuperview];
        }
        if ([self transportControlsView].superview == mediaControlsView){
            [[self transportControlsView] removeFromSuperview];
        }
        if ([self volumeView].superview == mediaControlsView){
            [[self volumeView] removeFromSuperview];
        }
        
        
        if (!self.acapella){
            self.acapella = [[%c(SWAcapellaBase) alloc] init];
            self.acapella.delegateAcapella = self;
        }
        
        self.acapella.frame = mediaControlsView.frame;
        [mediaControlsView.superview addSubview:self.acapella];
        
        [self trackInformationView].userInteractionEnabled = NO;
        
        if ([self timeInformationView].frame.size.height * 2.0 != self.acapella.acapellaTopAccessoryHeight){
            self.acapella.acapellaTopAccessoryHeight = [self timeInformationView].frame.size.height * 2.0;
        }
        
        if ([self volumeView].frame.size.height * 2.0 != self.acapella.acapellaBottomAccessoryHeight){
            self.acapella.acapellaBottomAccessoryHeight = [self volumeView].frame.size.height * 2.0;
        }
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
    
    if (self.acapella){
        if (self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:NO];
        }
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
    
    if (self.acapella){
        if (self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:NO];
        }
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)arg1
{
    %orig(arg1);
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig(arg1);
}

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
    if (tap.state == UIGestureRecognizerStateEnded){
        
        CGFloat percentBoundaries = 0.25;
        
        if (percentage.x <= percentBoundaries){ //left
            [%c(AVSystemController) acapellaChangeVolume:-1];
        } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
            
            SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
            
            if (sbMediaController){
                [sbMediaController togglePlayPause];
            }
            
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 view.tableview.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      view.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      view.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
            
        } else if (percentage.x > (1.0 - percentBoundaries)){ //right
            [%c(AVSystemController) acapellaChangeVolume:1];
        }
        
    }
}

%new
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
    
    if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
        
        if (sbMediaController && [sbMediaController _nowPlayingInfo]){ //make sure something is playing
            
            [view stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated
            
            long skipDirection = (direction == SW_SCROLL_DIR_LEFT) ? -1 : 1;
            [sbMediaController changeTrack:(int)skipDirection];
            
        } else {
            [view finishWrapAroundAnimation];
        }
        
    } else {
        [view finishWrapAroundAnimation];
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
    void (^_openNowPlayingApp)() = ^(){
        
        MPUNowPlayingController *nowPlayingController = MSHookIvar<MPUNowPlayingController *>(self, "_nowPlayingController");
        
        if (nowPlayingController){
            
            SBApplicationController *sbAppController = [%c(SBApplicationController) sharedInstanceIfExists];
            
            if (sbAppController){
                SBApplication *nowPlayingApp = [sbAppController applicationWithDisplayIdentifier:nowPlayingController.nowPlayingAppDisplayID];
                
                if (!nowPlayingApp){ //fallback
                    nowPlayingApp = [sbAppController applicationWithDisplayIdentifier:@"com.apple.Music"];
                }
                
                [%c(SWAppLauncher) launchAppLockscreenFriendly:nowPlayingApp];
            }
            
        }
        
    };
    
    
    
    void (^_doSeek)(BOOL on, int speed) = ^(BOOL on, int speed){
        
        SBMediaController *sbMediaController = [%c(SBMediaController) sharedInstance];
        
        if (sbMediaController){
            
            if (on){
                [sbMediaController beginSeek:speed];
            } else {
                [sbMediaController endSeek:speed];
            }
            
        }
        
    };
    
        
        
        
        
    CGFloat percentBoundaries = 0.25;
    
    if (percentage.x <= percentBoundaries){ //left
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            _doSeek(YES, -1);
        } else if (longPress.state == UIGestureRecognizerStateEnded){
            _doSeek(NO, -1);
        }
        
    } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            _openNowPlayingApp();
        }
        
    } else if (percentage.x > (1.0 - percentBoundaries)){ //right
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            _doSeek(YES, 1);
        } else if (longPress.state == UIGestureRecognizerStateEnded){
            _doSeek(NO, 1);
        }
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UIView *mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");
    
    if (mediaControlsView){
        
        if (indexPath.section == 0){
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                case 1:
                    
                    if ([self volumeView]){
                        [[self volumeView] removeFromSuperview];
                    }
                    
                    if ([self timeInformationView]){
                        [cell addSubview:[self timeInformationView]];
                    }
                    
                    break;
                    
                case 2:
                    
                    if ([self trackInformationView] && view.scrollview){
                        [view.scrollview addSubview:[self trackInformationView]];
                    }
                    
                    break;
                    
                case 3:
                    
                    if ([self timeInformationView]){
                        [[self timeInformationView] removeFromSuperview];
                    }
                    
                    if ([self volumeView]){
                        [cell addSubview:[self volumeView]];
                    }
                    
                    break;
                    
                case 4:
                    
                    break;
                    
                default:
                    break;
            }
        }
        
        [mediaControlsView layoutSubviews];
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

%end





#pragma mark SBCCMediaControlsSectionController

%hook SBCCMediaControlsSectionController

- (CGSize)contentSizeForOrientation:(long long)arg1
{
    CGSize original = %orig(arg1);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return CGSizeMake(original.width, original.height * 0.80);
    }
    
    return original;
}

%end





%hook MPUChronologicalProgressView

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")]){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





%hook MPUMediaControlsVolumeView

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
    if ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")]){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





#pragma mark logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}