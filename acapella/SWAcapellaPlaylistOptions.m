
#import "SWAcapellaPlaylistOptions.h"

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>

#define Y_PADDING 5
#define X_PADDING 10

@interface SWAcapellaPlaylistOptions()
{
}

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) UIButton *repeatButton;
@property (strong, nonatomic) UIButton *geniusButton;
@property (strong, nonatomic) UIButton *shuffleButton;

@end




@implementation SWAcapellaPlaylistOptions

- (id)init
{
    self = [super init];
    
    if (self){
        self.shouldShowGeniusButton = NO;
    }
    
    return self;
}

- (void)create
{
    if (!self.delegate){
        return;
    }
    
    if (!self.repeatButton){
        self.repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.repeatButton layer] setMasksToBounds:YES];
        [[self.repeatButton layer] setCornerRadius:5.0f];
        [self.repeatButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.shouldShowGeniusButton && !self.geniusButton){
        self.geniusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.geniusButton layer] setMasksToBounds:YES];
        [[self.geniusButton layer] setCornerRadius:5.0f];
        [self.geniusButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!self.shuffleButton){
        self.shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [[self.shuffleButton layer] setMasksToBounds:YES];
        [[self.shuffleButton layer] setCornerRadius:5.0f];
        [self.shuffleButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (BOOL)created
{
    return self.repeatButton && (self.shouldShowGeniusButton ? (self.geniusButton != nil) : YES) && self.shuffleButton;
}

- (void)cleanup
{
    [self stopHideTimer];
    
    if (self.repeatButton){
        [self.repeatButton removeFromSuperview];
        self.repeatButton = nil;
    }
    
    if (self.geniusButton){
        [self.geniusButton removeFromSuperview];
        self.geniusButton = nil;
    }
    
    if (self.shuffleButton){
        [self.shuffleButton removeFromSuperview];
        self.shuffleButton = nil;
    }
}

- (void)layoutToScrollView:(UIScrollView *)scrollview
{
    if (!scrollview){
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.repeatButton){
            
            [self.repeatButton setOrigin:CGPointMake((scrollview.contentSize.width /
                                                      [scrollview pagesAvailable].x) + X_PADDING,
                                                     (scrollview.contentSize.height /
                                                      [scrollview pagesAvailable].y) -
                                                     self.repeatButton.frame.size.height - Y_PADDING)];
            
            [scrollview addSubview:self.repeatButton];
            
        }
        
        if (self.geniusButton){
            
            [self.geniusButton setCenterX:scrollview.contentSize.width / 2];
            [self.geniusButton setOriginY:self.repeatButton.frame.origin.y];
            
            [scrollview addSubview:self.geniusButton];
            
        }
        
        if (self.shuffleButton){
            
            [self.shuffleButton setOrigin:CGPointMake(((scrollview.contentSize.width /
                                                        [scrollview pagesAvailable].x) + scrollview.frame.size.width) -
                                                      self.shuffleButton.frame.size.width - X_PADDING,
                                                      self.repeatButton.frame.origin.y)];
            
            [scrollview addSubview:self.shuffleButton];
            
        }
    }];
}

- (void)startHideTimer
{
    [self stopHideTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                   block:^{
                                                       [UIView animateWithDuration:0.4
                                                                             delay:0.0
                                                                           options:UIViewAnimationOptionCurveEaseInOut
                                                                        animations:^{
                                                                            if (self.repeatButton){
                                                                                self.repeatButton.alpha = 0.0;
                                                                            }
                                                                            if (self.geniusButton){
                                                                                self.geniusButton.alpha = 0.0;
                                                                            }
                                                                            if (self.shuffleButton){
                                                                                self.shuffleButton.alpha = 0.0;
                                                                            }
                                                                        }
                                                                        completion:^(BOOL finished){
                                                                            
                                                                            [self cleanup];
                                                                            
                                                                        }];
                                                   }repeats:NO];
}

- (void)stopHideTimer
{
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (UIButton *)updateButtonAtIndex:(NSInteger)index
                             text:(NSString *)text
                             font:(UIFont *)font
                     buttonColour:(UIColor *)buttonColour
                       textColour:(UIColor *)textColour
{
    UIButton *button;
    
    if (index == 0){
        
        button = self.repeatButton;
        
    } else if (index == 1){
        
        button = self.geniusButton;
        
    } else if (index == 2){
        
        button = self.shuffleButton;
        
    }
    
    if (button){
        
        button.backgroundColor = buttonColour;
        
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:text
                                                                   attributes:@{NSForegroundColorAttributeName:textColour,
                                                                                NSFontAttributeName:font}]
                          forState:UIControlStateNormal];
        
        [button sizeToFit];
    }
    
    return button;
}

- (void)buttonTapped:(UIButton *)button
{
    if (!button){
        return;
    }
    
    [self startHideTimer]; //reset timer
    
    NSInteger buttonIndex = -1;
    
    if (button == self.repeatButton){
        buttonIndex = 0;
    } else if (button == self.geniusButton){
        buttonIndex = 1;
    } else if (button == self.shuffleButton){
        buttonIndex = 2;
    }
    
    if (buttonIndex >= 0){
        [self.delegate swAcapellaPlaylistOptions:self buttonTapped:button withIndex:buttonIndex];
    }
}

@end




