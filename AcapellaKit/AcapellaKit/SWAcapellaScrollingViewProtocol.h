//
//  SWAcapellaScrollingViewProtocol.h
//  AcapellaKit
//
//  Created by Pat Sluth on 2015-05-06.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

typedef enum SWScrollDirection {
    SWScrollDirectionNone,
    SWScrollDirectionLeft,
    SWScrollDirectionRight,
    SWScrollDirectionUp,
    SWScrollDirectionDown
} SWScrollDirection;





@protocol SWAcapellaScrollingViewProtocol <NSObject>

@required

@property (readwrite, nonatomic) CGPoint contentOffset;
@property (readwrite, nonatomic) CGPoint previousContentOffset;
@property (readonly, nonatomic) CGPoint defaultContentOffset;

@property (readwrite, nonatomic) SWScrollDirection currentScrollDirection;

- (void)resetContentOffset:(BOOL)animated;

@optional

@end




