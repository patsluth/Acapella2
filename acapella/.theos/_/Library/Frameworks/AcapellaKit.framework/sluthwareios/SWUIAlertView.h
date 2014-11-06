//
//  SWUIAlertView.h
//  sluthwareios
//
//  Created by Pat Sluth on 2014-03-10.
//  Copyright (c) 2014 Sluthware. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SWUIAlertViewBlock)(UIAlertView *uiAlert, NSInteger buttonIndex);

@interface SWUIAlertView : UIAlertView <UIAlertViewDelegate>

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
         clickedButtonBlock:(SWUIAlertViewBlock)clickedButton
        didDismissBlock:(SWUIAlertViewBlock)didDismiss
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end




