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

- (id)init
{
    self = [super init];
    
    if (self) {
        
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
        self.itemLabelTop.lineBreakMode = NSLineBreakByTruncatingTail;
        self.itemLabelTop.backgroundColor = [UIColor clearColor];
        self.itemLabelTop.text = @"Nothing Playing";
        
        
        self.itemLabelMiddle = [[UILabel alloc] init];
        [self.view addSubview:self.itemLabelMiddle];
        self.itemLabelMiddle.translatesAutoresizingMaskIntoConstraints = NO;
        self.itemLabelMiddle.lineBreakMode = NSLineBreakByTruncatingTail;
        self.itemLabelMiddle.backgroundColor = [UIColor clearColor];
        
        
        self.itemLabelBottom = [[UILabel alloc] init];
        [self.view addSubview:self.itemLabelBottom];
        self.itemLabelBottom.translatesAutoresizingMaskIntoConstraints = NO;
        self.itemLabelBottom.lineBreakMode = NSLineBreakByTruncatingTail;
        self.itemLabelBottom.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat artworkInset = 16; // inset copied from MusicContextualActionsHeaderViewController (Used in cello)
    
    // Subract the artworkInset from the top and bottom so it is even
    [self.itemArtwork.widthAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:1.0 constant:(artworkInset * -2)].active = YES;
    [self.itemArtwork.heightAnchor constraintEqualToAnchor:self.itemArtwork.widthAnchor multiplier:1.0].active = YES;
    [self.itemArtwork.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:artworkInset].active = YES;
    [self.itemArtwork.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    
    
    [self.itemLabelTop.topAnchor constraintEqualToAnchor:self.itemArtwork.topAnchor].active = YES;
    [self.itemLabelTop.leftAnchor constraintEqualToAnchor:self.itemArtwork.rightAnchor constant:artworkInset].active = YES;
    [self.itemLabelTop.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-artworkInset].active = YES;
    
    
    [self.itemLabelMiddle.topAnchor constraintEqualToAnchor:self.itemLabelTop.bottomAnchor].active = YES;
    [self.itemLabelMiddle.leftAnchor constraintEqualToAnchor:self.itemArtwork.rightAnchor constant:artworkInset].active = YES;
    [self.itemLabelMiddle.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-artworkInset].active = YES;
    
    
    [self.itemLabelBottom.topAnchor constraintEqualToAnchor:self.itemLabelMiddle.bottomAnchor].active = YES;
    [self.itemLabelBottom.leftAnchor constraintEqualToAnchor:self.itemArtwork.rightAnchor constant:artworkInset].active = YES;
    [self.itemLabelBottom.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-artworkInset].active = YES;
}

- (void)configureWithCurrentNowPlayingInfo
{
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
        
        NSDictionary *nowPlayingInfo = (__bridge NSDictionary *)result;
        
        if (nowPlayingInfo){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                NSData *artworkData = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
                UIImage *artworkImage = [[UIImage alloc] initWithData:artworkData];
                
                if (!artworkImage) { // Load apple default missing artwork image
                    NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FuseUI.framework"];
                    artworkImage = [UIImage imageNamed:@"MissingSongArtworkGenericProxy" inBundle:bundle compatibleWithTraitCollection:nil];
                }
                
                self.itemArtwork.image = artworkImage;
                
                self.itemLabelTop.text = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                self.itemLabelMiddle.text = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
                self.itemLabelBottom.text = [nowPlayingInfo valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];
                
            });
        }
        
    });
}

@end



