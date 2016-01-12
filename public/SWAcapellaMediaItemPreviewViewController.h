//
//  SWAcapellaMediaItemPreviewViewController.h
//  Acapella2
//
//  Created by Pat Sluth on 2016-01-11.
//  Copyright © 2016 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface SWAcapellaMediaItemPreviewViewController : UIViewController
{
}

@property (strong, nonatomic, readonly) UIImageView *itemArtwork;

@property (strong, nonatomic, readonly) UILabel *itemLabelTop;
@property (strong, nonatomic, readonly) UILabel *itemLabelMiddle;
@property (strong, nonatomic, readonly) UILabel *itemLabelBottom;

- (void)configureWithCurrentNowPlayingInfo;

@end




