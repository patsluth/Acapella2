//
//  SWAcapellaMediaItemPreviewViewController.h
//  Acapella2
//
//  Created by Pat Sluth on 2016-01-11.
//  Copyright © 2016 Pat Sluth. All rights reserved.
//

@import UIKit;

#import "SWAcapellaDelegate.h"





@interface SWAcapellaMediaItemPreviewViewController : UIViewController
{
}

@property (weak, nonatomic) UIViewController<SWAcapellaDelegate> *delegate;

@property (strong, nonatomic, readonly) UIImageView *itemArtwork;

@property (strong, nonatomic, readonly) UILabel *itemLabelTop;
@property (strong, nonatomic, readonly) UILabel *itemLabelMiddle;
@property (strong, nonatomic, readonly) UILabel *itemLabelBottom;

@property (strong, nonatomic) NSString *popAction;
@property (strong, nonatomic) NSArray *acapellaPreviewActionItems;

- (id)initWithDelegate:(UIViewController<SWAcapellaDelegate> *)delegate;
- (void)configureWithCurrentNowPlayingInfo;


// UIPreviewActions
- (UIPreviewAction *)heartAction;
- (UIPreviewAction *)upNextAction;
- (UIPreviewAction *)previousTrackAction;
- (UIPreviewAction *)nextTrackAction;
- (UIPreviewAction *)intervalRewindAction;
- (UIPreviewAction *)intervalForwardAction;
- (UIPreviewAction *)seekRewindAction;
- (UIPreviewAction *)seekForwardAction;
- (UIPreviewAction *)playPauseAction;
- (UIPreviewAction *)shareAction;
- (UIPreviewAction *)shuffleAction;
- (UIPreviewAction *)toggleRepeatAction;
- (UIPreviewAction *)contextualAction;
- (UIPreviewAction *)openAppAction;
- (UIPreviewAction *)showRatingsAction;
- (UIPreviewAction *)decreaseVolumeAction;
- (UIPreviewAction *)increaseVolumeAction;
- (UIPreviewAction *)equalizerEverywhereAction;

@end




