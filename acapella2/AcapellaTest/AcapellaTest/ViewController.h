//
//  ViewController.h
//  AcapellaTest
//
//  Created by Pat Sluth on 2014-10-26.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWAcapella.h"





@interface ViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *top;
@property (strong, nonatomic) IBOutlet UIView *dragView;
@property (strong, nonatomic) IBOutlet UIView *bottom;

@end




