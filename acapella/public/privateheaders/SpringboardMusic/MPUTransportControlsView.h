
@class MPUTransportButton;

@interface MPUTransportControlsView : UIView
{
    //iOS 7
    
    
    //iOS 8
    NSArray *_availableControls;
    MPUTransportButton *_rightButton;
}

//iOS 8
@property (copy) NSArray *availableControls;

@end




