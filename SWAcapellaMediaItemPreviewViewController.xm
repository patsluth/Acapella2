//
//  SWAcapellaMediaItemPreviewViewController.m
//  Acapella2
//
//  Created by Pat Sluth on 2016-01-11.
//  Copyright © 2016 Pat Sluth. All rights reserved.
//

#import "SWAcapellaMediaItemPreviewViewController.h"

#import <MediaRemote/MediaRemote.h>





@interface SWAcapellaMediaItemPreviewViewController()
{
}

@property (strong, nonatomic, readwrite) UIImageView *itemArtwork;

@property (strong, nonatomic, readwrite) UILabel *itemLabelTop;
@property (strong, nonatomic, readwrite) UILabel *itemLabelMiddle;
@property (strong, nonatomic, readwrite) UILabel *itemLabelBottom;

@end





@implementation SWAcapellaMediaItemPreviewViewController

#pragma mark - Init

- (id)initWithDelegate:(UIViewController<SWAcapellaDelegate> *)delegate
{
    self = [super init];
    
    if (self) {
        
        //self.delegate = delegate;
        
        // Height copied from MusicContextualActionsHeaderViewController (Used in cello)
        self.preferredContentSize = CGSizeMake(0.0, 124);
        
        self.view = [[UIView alloc] init];
        self.view.backgroundColor = [UIColor whiteColor];
        self.view.alpha = 1.0;
        
        
        self.itemArtwork = [[UIImageView alloc] init];
        [self.view addSubview:self.itemArtwork];
        self.itemArtwork.translatesAutoresizingMaskIntoConstraints = NO;
        self.itemArtwork.contentMode = UIViewContentModeScaleAspectFit;
        self.itemArtwork.backgroundColor = [UIColor lightGrayColor];
        
        
        self.itemLabelTop = [[UILabel alloc] init];
        [self.view addSubview:self.itemLabelTop];
        self.itemLabelTop.translatesAutoresizingMaskIntoConstraints = NO;
        self.itemLabelTop.font = [UIFont fontWithName:@".SFUIText-Medium" size:17.0];
        self.itemLabelTop.lineBreakMode = NSLineBreakByTruncatingTail;
        self.itemLabelTop.backgroundColor = [UIColor clearColor];
        self.itemLabelTop.text = @"Nothing Playing";
        
        
        self.itemLabelMiddle = [[UILabel alloc] init];
        [self.view addSubview:self.itemLabelMiddle];
        self.itemLabelMiddle.translatesAutoresizingMaskIntoConstraints = NO;
        self.itemLabelMiddle.font = [UIFont fontWithName:@".SFUIText-Regular" size:12.0];
        self.itemLabelMiddle.lineBreakMode = NSLineBreakByTruncatingTail;
        self.itemLabelMiddle.backgroundColor = [UIColor clearColor];
        
        
        self.itemLabelBottom = [[UILabel alloc] init];
        [self.view addSubview:self.itemLabelBottom];
        self.itemLabelBottom.translatesAutoresizingMaskIntoConstraints = NO;
        self.itemLabelBottom.font = [UIFont fontWithName:@".SFUIText-Regular" size:12.0];
        self.itemLabelBottom.alpha = 0.4;
        self.itemLabelBottom.lineBreakMode = NSLineBreakByTruncatingTail;
        self.itemLabelBottom.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // insets copied from MusicContextualActionsHeaderViewController (Used in cello)
    CGFloat artworkInset = 16;
    CGFloat labelInset = 12;

    // Subract the artworkInset from the top and bottom so it is even
    [self.itemArtwork.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:1.0 constant:(artworkInset * -2)].active = YES;
    [self.itemArtwork.heightAnchor constraintEqualToAnchor:self.itemArtwork.widthAnchor multiplier:1.0].active = YES;
    [self.itemArtwork.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:artworkInset].active = YES;
    [self.itemArtwork.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    
    [self.itemLabelTop.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:labelInset].active = YES;
    [self.itemLabelTop.leftAnchor constraintEqualToAnchor:self.itemArtwork.rightAnchor constant:labelInset].active = YES;
    [self.itemLabelTop.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-labelInset].active = YES;
    
    
    [self.itemLabelMiddle.topAnchor constraintEqualToAnchor:self.itemLabelTop.bottomAnchor].active = YES;
    [self.itemLabelMiddle.leftAnchor constraintEqualToAnchor:self.itemArtwork.rightAnchor constant:labelInset].active = YES;
    [self.itemLabelMiddle.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-labelInset].active = YES;
    
    
    // 1.5 multiplier copied from MusicContextualActionsHeaderViewController (Used in cello)
    [self.itemLabelBottom.topAnchor constraintEqualToAnchor:self.itemLabelMiddle.bottomAnchor constant:1.5].active = YES;
    [self.itemLabelBottom.leftAnchor constraintEqualToAnchor:self.itemArtwork.rightAnchor constant:labelInset].active = YES;
    [self.itemLabelBottom.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-labelInset].active = YES;
}

- (void)configureWithCurrentNowPlayingInfo
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *nowPlayingInfo = (__bridge NSDictionary *)result;
        
        if (nowPlayingInfo){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                NSData *artworkData = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
                UIImage *artworkImage = [[UIImage alloc] initWithData:artworkData scale:[[UIScreen mainScreen] scale]];

                if (!artworkImage) { // Load apple default missing artwork image
                    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FuseUI.framework"];
                    artworkImage = [UIImage imageNamed:@"MissingSongArtworkGenericProxy" inBundle:bundle compatibleWithTraitCollection:nil];
                }
                
                self.itemArtwork.image = artworkImage;
                
                self.itemLabelTop.text = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                self.itemLabelMiddle.text = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];
                self.itemLabelBottom.text = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
                
            });
        }
        
    });
}

#pragma mark - UIPreviewActions

// UIPreviewActions
- (UIPreviewAction *)heartAction
{
    return [UIPreviewAction actionWithTitle:@"Heart"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_heart:nil];
                                    }];
}

- (UIPreviewAction *)upNextAction
{
    return [UIPreviewAction actionWithTitle:@"Up Next"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_upnext:nil];
                                    }];
}

- (UIPreviewAction *)previousTrackAction
{
    return [UIPreviewAction actionWithTitle:@"Previous Track"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_previoustrack:nil];
                                    }];
}

- (UIPreviewAction *)nextTrackAction
{
    return [UIPreviewAction actionWithTitle:@"Next Track"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_nexttrack:nil];
                                    }];
}

- (UIPreviewAction *)intervalRewindAction
{
    return [UIPreviewAction actionWithTitle:@"Interval Rewind"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_intervalrewind:nil];
                                    }];
}

- (UIPreviewAction *)intervalForwardAction
{
    return [UIPreviewAction actionWithTitle:@"Interval Forward"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_intervalforward:nil];
                                    }];
}

- (UIPreviewAction *)seekRewindAction
{
    return [UIPreviewAction actionWithTitle:@"Seek Rewind"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_seekrewind:nil];
                                    }];
}

- (UIPreviewAction *)seekForwardAction
{
    return [UIPreviewAction actionWithTitle:@"Seek Forward"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_seekforward:nil];
                                    }];
}

- (UIPreviewAction *)playPauseAction
{
    return [UIPreviewAction actionWithTitle:@"Play/Pause"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_playpause:nil];
                                    }];
}

- (UIPreviewAction *)shareAction
{
    return [UIPreviewAction actionWithTitle:@"Share"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_share:nil];
                                    }];
}

- (UIPreviewAction *)shuffleAction
{
    return [UIPreviewAction actionWithTitle:@"Toggle Shuffle"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_toggleshuffle:nil];
                                    }];
}

- (UIPreviewAction *)toggleRepeatAction
{
    return [UIPreviewAction actionWithTitle:@"Toggle Repeat"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_togglerepeat:nil];
                                    }];
}

- (UIPreviewAction *)contextualAction
{
    return [UIPreviewAction actionWithTitle:@"Contextual"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_contextual:nil];
                                    }];
}

- (UIPreviewAction *)openAppAction
{
    return [UIPreviewAction actionWithTitle:@"Open Now Playing App"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_openapp:nil];
                                    }];
}

- (UIPreviewAction *)showRatingsAction
{
    return [UIPreviewAction actionWithTitle:@"Show Ratings"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_showratings:nil];
                                    }];
}

- (UIPreviewAction *)decreaseVolumeAction
{
    return [UIPreviewAction actionWithTitle:@"Decrease Volume"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_decreasevolume:nil];
                                    }];
}

- (UIPreviewAction *)increaseVolumeAction
{
    return [UIPreviewAction actionWithTitle:@"Increase Volume"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_increasevolume:nil];
                                    }];
}

- (UIPreviewAction *)equalizerEverywhereAction
{
    return [UIPreviewAction actionWithTitle:@"Equalizer Everywhere"
                                      style:UIPreviewActionStyleDefault
                                    handler:^(id<UIPreviewActionItem> action, UIViewController *previewViewController) {
                                        [((SWAcapellaMediaItemPreviewViewController *)previewViewController).delegate action_equalizereverywhere:nil];
                                    }];
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    if (self.acapellaPreviewActionItems && self.acapellaPreviewActionItems.count > 0) {
        return self.acapellaPreviewActionItems;
    }
    
    return [super previewActionItems];
}

@end




