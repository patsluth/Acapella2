

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>

#import "MusicNowPlayingViewController+SW.h"
#import "MPAVController.h"
#import "MPUNowPlayingTitlesView.h"
#import "MPDetailSlider.h"
#import "MPVolumeSlider.h"
#import "AVSystemController+SW.h"

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
- (MPAVController *)player
{
return MSHookIvar<MPAVController *>([self playbackControlsView], "_player");
}

%new
- (UIView *)progressControl
{
return MSHookIvar<UIView *>([self playbackControlsView], "_progressControl");
}

%new
- (UIView *)transportControls
{
return MSHookIvar<UIView *>([self playbackControlsView], "_transportControls");
}

%new
- (UIView *)volumeSlider
{
return MSHookIvar<UIView *>([self playbackControlsView], "_volumeSlider");
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
- (UIView *)repeatButton
{
return MSHookIvar<UIView *>([self playbackControlsView], "_repeatButton");
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
self.acapella.delegateAcapella = self;
}

CGFloat artworkBottomYOrigin = [self artworkView].frame.origin.y + [self artworkView].frame.size.height;
//set the bottom acapella origin to the top of the repeat button. Set it to the bottom of the view if repeat button hasnt been set up yet.
CGFloat bottomAcapellaYOrigin = (([self repeatButton].frame.origin.y <= 0.0) ?
[self playbackControlsView].frame.origin.y + [self playbackControlsView].frame.size.height :
[self repeatButton].frame.origin.y)
- artworkBottomYOrigin;

self.acapella.frame = CGRectMake([self playbackControlsView].frame.origin.x,
artworkBottomYOrigin,
//the space between the bottom of the artowrk and the bottom of the screen
[self playbackControlsView].frame.size.width,
bottomAcapellaYOrigin);

[[self playbackControlsView] addSubview:self.acapella];
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

if ([self progressControl].frame.size.height != self.acapella.acapellaTopAccessoryHeight){
self.acapella.acapellaTopAccessoryHeight = [self progressControl].frame.size.height;
}

if ([self volumeSlider].frame.size.height != self.acapella.acapellaBottomAccessoryHeight){
self.acapella.acapellaBottomAccessoryHeight = [self volumeSlider].frame.size.height;
}

}
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

#pragma mark SWAcapellaDelegate

%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
if (tap.state == UIGestureRecognizerStateEnded){

CGFloat percentBoundaries = 0.25;

if (percentage.x <= percentBoundaries){ //left
[%c(AVSystemController) acapellaChangeVolume:-1];
} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre

if (self.player){
[self.player togglePlayback];
}

[UIView animateWithDuration:0.1
animations:^{
view.scrollview.transform = CGAffineTransformMakeScale(0.9, 0.9);
} completion:^(BOOL finished){
[UIView animateWithDuration:0.1
animations:^{
view.scrollview.transform = CGAffineTransformMakeScale(1.0, 1.0);
} completion:^(BOOL finished){
view.scrollview.transform = CGAffineTransformMakeScale(1.0, 1.0);
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
if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){

if (self.player){

[view stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated

long skipDirection = (direction == SW_SCROLL_DIR_LEFT) ? -1 : 1;
[[NSOperationQueue mainQueue] addOperationWithBlock:^{
[self.player changePlaybackIndexBy:(int)skipDirection deltaType:0 ignoreElapsedTime:NO allowSkippingUnskippableContent:YES];
}];

} else {
[view finishWrapAroundAnimation];
}

} else if (direction == SW_SCROLL_DIR_UP){

} else {
[view finishWrapAroundAnimation];
}
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
MPAVController *p = [self player];
CGFloat percentBoundaries = 0.25;

if (percentage.x <= percentBoundaries){ //left

if (longPress.state == UIGestureRecognizerStateBegan){

if (p && [p canSeekBackwards]){
[p beginSeek:-1];
}

} else if (longPress.state == UIGestureRecognizerStateEnded){

[p endSeek];

}

} else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre

if (longPress.state == UIGestureRecognizerStateBegan){
//_openNowPlayingApp();
}

} else if (percentage.x > (1.0 - percentBoundaries)){ //right

if (longPress.state == UIGestureRecognizerStateBegan){

if (p && [p canSeekForwards]){
[p beginSeek:1];
}

} else if (longPress.state == UIGestureRecognizerStateEnded){

[p endSeek];

}

}
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
if ([self playbackControlsView]){

if (indexPath.section == 0){
switch (indexPath.row) {
case 0:

break;

case 1:

if ([self volumeSlider]){
[[self volumeSlider] removeFromSuperview];
}

if ([self progressControl]){
[cell addSubview:[self progressControl]];
[[self progressControl] setFrame:[self progressControl].frame]; //update our frame because are forcing centre in setRect:
}

break;

case 2:

[view.scrollview addSubview:[self titlesView]];
[[self titlesView] setFrame:[self titlesView].frame]; //update our frame because are forcing centre in setRect:

break;

case 3:

if ([self progressControl]){
[[self progressControl] removeFromSuperview];
}

if ([self volumeSlider]){
[cell addSubview:[self volumeSlider]];
[[self volumeSlider] setFrame:[self volumeSlider].frame]; //update our frame because are forcing centre in setRect:
}

break;

case 4:

break;

default:
break;
}
}

}
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark Other

- (void)_updateForCurrentItemAnimated:(BOOL)arg1
{
%orig(NO); //for some reason if we animate our scroll view while the album art change is animating, it is very jumpy
}

%end





%hook MPDetailSlider

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





%hook MPVolumeSlider

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