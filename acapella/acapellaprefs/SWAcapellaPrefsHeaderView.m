
#import "SWAcapellaPrefsHeaderView.h"

#import "SWAcapellaPrefsHelper.h"
#import <libsw/sluthwareios/sluthwareios.h>

@interface SWAcapellaPrefsHeaderView()
{
}

@property (strong, nonatomic) UIImageView *acapellaImage;
@property (strong, nonatomic) UILabel *acapellaText;

@end





@implementation SWAcapellaPrefsHeaderView

- (id)initWithImage:(UIImage *)image
{
	self = [super initWithImage:image];
	
	if (self){
	
		self.contentMode = UIViewContentModeScaleToFill;
		
		NSBundle *bundle = [NSBundle bundleWithPath:SW_ACAPELLA_PREFS_BUNDLE_PATH];
    
		if (bundle){
    		self.acapellaImage = [[UIImageView alloc] initWithImage:[UIImage
    																imageWithContentsOfFile:[bundle
    																pathForResource:@"Acapella_Prefs_Banner_Image" ofType:@"png"]]];
    		self.acapellaImage.contentMode = UIViewContentModeScaleAspectFit;
    		[self addSubview:self.acapellaImage];
    	}
	
		self.acapellaText = [[UILabel alloc] init];
		self.acapellaText.text = @"Acapella";
		self.acapellaText.textColor = [UIColor whiteColor];
		
		[self addSubview:self.acapellaText];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self.acapellaImage setSize:CGSizeMake(self.frame.size.height / 3, self.frame.size.height / 3)];
	[self.acapellaImage setCenterX:self.frame.size.width / 2];
	
	//stretch our views
	self.acapellaText.font = [UIFont systemFontOfSize:self.frame.size.height / 5];
	[self.acapellaText sizeToFit];
	[self.acapellaText setOriginY:self.frame.size.height - self.acapellaText.frame.size.height - 10]; //10 pixel padding
	[self.acapellaText setCenterX:self.frame.size.width / 2];
	
	[self.acapellaImage setOriginY:self.acapellaText.frame.origin.y - self.acapellaImage.frame.size.height];
}

@end









