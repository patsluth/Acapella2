

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>

#import "MusicNowPlayingViewController+SW.h"
#import "MPUNowPlayingTitlesView.h"

#import "substrate.h"
#import <objc/runtime.h>





#pragma mark MusicNowPlayingViewController

static SWAcapellaBase *_acapella;
static NSNotification *_titleTextChangeNotification;

%hook MusicNowPlayingViewController

#pragma mark Helper

%new
- (UIView *)playbackControlsView
{
    return MSHookIvar<UIView *>(self, "_playbackControlsView");
}

%new
- (UIView *)progressControl
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_progressControl");
    }
    
    return nil;
}

%new
- (UIView *)transportControls
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_transportControls");
    }
    
    return nil;
}

%new
- (UIView *)volumeSlider
{
    if ([self playbackControlsView]){
        return MSHookIvar<UIView *>([self playbackControlsView], "_volumeSlider");
    }
    
    return nil;
}

%new
- (UIView *)ratingControl
{
    return MSHookIvar<UIView *>(self, "_ratingControl");
}

%new
- (UIView *)titlesView
{
    return MSHookIvar<UIView *>(self, "_titlesView");
}

%new
- (UIImageView *)artworkView
{
    UIView *artwork = MSHookIvar<UIView *>(self, "_contentView");
    
    if (artwork && [artwork isKindOfClass:[UIImageView class]]){
        return (UIImageView *)artwork;
    }
    
    return nil;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTitleTextDidChangeNotification:)
                                                 name:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText"
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    //return;
    
    if ([self playbackControlsView]){
        
        if ([self progressControl].superview){
            [[self progressControl] removeFromSuperview];
        }
        
        if ([self transportControls].superview){
            [[self transportControls] removeFromSuperview];
        }
        
        if ([self volumeSlider].superview){
            [[self volumeSlider] removeFromSuperview];
        }
        
        if ([self titlesView].superview){
            [[self titlesView] removeFromSuperview];
        }
        
        if ([self artworkView]){
            
            if (!self.acapella){
                self.acapella = [[%c(SWAcapellaBase) alloc] init];
                self.acapella.backgroundColor = [UIColor blueColor];
                self.acapella.delegateAcapella = self;
            }
            
            CGFloat artworkBottomYOrigin = [self artworkView].frame.origin.y + [self artworkView].frame.size.height;
            
            self.acapella.frame = CGRectMake([self playbackControlsView].frame.origin.x,
                                             artworkBottomYOrigin,
                                             //the space between the bottom of the artowrk and the bottom of the screen
                                             [self playbackControlsView].frame.size.width,
                                             ([self playbackControlsView].frame.origin.y + [self playbackControlsView].frame.size.height) - artworkBottomYOrigin);
            
            [[self playbackControlsView] addSubview:self.acapella];
            
            if (self.acapella){
                [self.acapella.tableview resetContentOffset:NO];
                [self.acapella.scrollview resetContentOffset:NO];
            }
        }
        
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)arg1
{
    %orig(arg1);
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig(arg1);
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SWAcapella_MPUNowPlayingTitlesView_setTitleText" object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2
{
    %orig(arg1, arg2);
    
    [self viewDidLayoutSubviews];
}

- (void)didRotateFromInterfaceOrientation:(int)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
}

#pragma mark Notification

%new
- (void)onTitleTextDidChangeNotification:(NSNotification *)notification
{
//    if (self.acapella && [self.acapella.scrollview page].x != 1){ //1 is the middle page
//        if ([self trackInformationView] && [self trackInformationView] == notification.object){
//            [self.acapella.scrollview finishWrapAroundAnimation];
//        }
//    }
}

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(CGPoint)percentage
{
    
}

%new
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
    
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(CGPoint)percentage
{
    
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Acapella Will Display Cell At Row %ld", (long)indexPath.row);
    
    if ([self playbackControlsView]){
        
        if (indexPath.section == 0){
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                case 1:
                    
//                    if ([self volumeView]){
//                        [[self volumeView] removeFromSuperview];
//                    }
//                    
//                    if ([self timeInformationView]){
//                        [cell addSubview:[self timeInformationView]];
//                    }
                    
                    break;
                    
                case 2:
                    
                     NSLog(@"PAT TEST TEST %@--%@", NSStringFromCGRect(view.scrollview.frame), NSStringFromCGSize(view.scrollview.contentSize));
                    
                    [view.scrollview addSubview:[self titlesView]];
                    [[self titlesView] setFrame:[self titlesView].frame];
                   // [self titlesView].center = CGPointMake(view.scrollview.contentSize.width / 2,
                   //                                        view.scrollview.contentSize.height / 2);
                    
                    //[self viewDidLayoutSubviews];
                    
                    return;
                    
                    if ([self titlesView] && view.scrollview){
                        
                        
                        
                        if ([self titlesView].superview != view.scrollview){
                            
                            [self titlesView].alpha = 0.0;
                            [view.scrollview addSubview:[self titlesView]];
                            
//                            [NSTimer scheduledTimerWithTimeInterval:0.5
//                                                              block:^{
                            
                                                                  [self titlesView].center = CGPointMake(view.scrollview.contentSize.width / 2,
                                                                                                         view.scrollview.contentSize.height / 2);
                                                                  
//                                                                  [UIView animateWithDuration:0.3
//                                                                                   animations:^{
//                                                                                       [self titlesView].alpha = 1.0;
//                                                                                   }completion:^(BOOL finished){
//                                                                                       [self titlesView].alpha = 1.0;
//                                                                                       [self titlesView].center = CGPointMake(view.scrollview.contentSize.width / 2,
//                                                                                                                              view.scrollview.contentSize.height / 2);
//                                                                                   }];
//                                                              }repeats:NO];
                            
                        }
                    }
                    
                    break;
                    
                case 3:
                    
//                    if ([self timeInformationView]){
//                        [[self timeInformationView] removeFromSuperview];
//                    }
//                    
//                    if ([self volumeView]){
//                        [cell addSubview:[self volumeView]];
//                    }
                    
                    break;
                    
                case 4:
                    
                    break;
                    
                default:
                    break;
            }
        }
        
        //[mediaControlsView layoutSubviews];
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

%end




//%hook MPUNowPlayingTitlesView
//
//- (void)setFrame:(CGRect)frame{
//    if ([self.superview isKindOfClass:[UIScrollView class]]){
//        
//        UIScrollView *superScrollView = (UIScrollView *)self.superview;
//        
//        if (superScrollView.delegate && [superScrollView.delegate isKindOfClass:%c(SWAcapellaBase)]){
//            
//            SWAcapellaBase *acapella = (SWAcapellaBase *)superScrollView.delegate;
//            
//            %orig(CGRectMake((superScrollView.contentSize.width / 2) - (frame.size.width / 2),
//                             (acapella.frame.size.height / 2) - (frame.size.height / 2),
//                             frame.size.width,
//                             frame.size.height));
//            
//            return;
//        }
//        
//    }
//    
//    %orig(frame);
//}
//
//%end





#pragma mark logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}