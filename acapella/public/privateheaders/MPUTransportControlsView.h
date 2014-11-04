
@protocol MPUTransportControlsViewDelegate <NSObject>

@optional
- (void)transportControlsView:(id)arg1 tapOnAccessoryButtonType:(int)arg2;
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(int)arg2;
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(int)arg2;
- (void)transportControlsView:(id)arg1 tapOnControlType:(int)arg2;

@end

@interface MPUTransportControlsView : UIView
{
    UIButton *_leftButton;
	UIButton *_middleButton;
	UIButton *_rightButton;
	UIButton *_shuffleButton;
	UIButton *_repeatButton;
    
	int _availableControls;
    
	id <MPUTransportControlsViewDelegate> _delegate;
}

@property (weak, nonatomic) id <MPUTransportControlsViewDelegate> delegate;
@property (assign,nonatomic) int availableControls;

- (void)_setImage:(id)arg1 forButton:(id)arg2;
- (void)_updateTransportControlButtons;

- (id)_leftButton;
- (id)_middleButton;
- (id)_rightButton;
- (id)_shuffleButton;
- (id)_repeatButton;

@end




