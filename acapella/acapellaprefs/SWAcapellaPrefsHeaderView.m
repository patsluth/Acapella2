
#import "SWAcapellaPrefsHeaderView.h"

#import "SWAcapellaPrefsBundle.h"
#import <libsw/sluthwareios/sluthwareios.h>

@interface SWAcapellaPrefsHeaderView()
{
}

@property (strong, nonatomic) UIImageView *acapellaIcon;
@property (strong, nonatomic) UILabel *acapellaText;

@end





@implementation SWAcapellaPrefsHeaderView

- (id)initWithImage:(UIImage *)image
{
	self = [super initWithImage:image];
	
	if (self){
	
		self.contentMode = UIViewContentModeScaleAspectFill;
	
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
	
	//stretch our views
	self.acapellaText.font = [UIFont systemFontOfSize:self.frame.size.height / 4];
	[self.acapellaText sizeToFit];
	[self.acapellaText setOriginY:self.frame.size.height - self.acapellaText.frame.size.height - 10]; //10 pixel padding
	[self.acapellaText setCenterX:self.frame.size.width / 2];
}

@end









