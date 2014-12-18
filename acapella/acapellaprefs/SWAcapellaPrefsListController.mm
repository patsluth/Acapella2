
#import "SWAcapellaPrefsHeaderView.h"

#import <libsw/sluthwareios/sluthwareios.h>
#import <libsw/SWPSTwitterCell.h>
#import <libpackageinfo/libpackageinfo.h>

#import <Preferences/Preferences.h>

#import "dlfcn.h"

#define SW_ACAPELLA_HEADER_HEIGHT 200

void *handle;

@interface SWAcapellaPrefsListController: PSListController <UIScrollViewDelegate>
{
}

@property (strong, nonatomic) SWAcapellaPrefsHeaderView *acapellaPrefsHeaderView;
@property (strong, nonatomic) PIDebianPackage *packageDEB;

@end

@implementation SWAcapellaPrefsListController

#pragma mark Init

-(id)init
{
     self = [super init];
     
     if(self){
         handle = dlopen("/usr/lib/libsw.dylib", RTLD_NOW | RTLD_GLOBAL);
     }
     
     return self;
}

- (id)specifiers
{
	if(_specifiers == nil){
		_specifiers = [self loadSpecifiersFromPlistName:@"AcapellaPrefs" target:self];
	}
	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([SWDeviceInfo iOSVersion_First] == 8){
	
		self.table.backgroundColor = [UIColor clearColor];
	
		UIView *tableViewHeader = [[UIView alloc] init];
	    tableViewHeader.frame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, SW_ACAPELLA_HEADER_HEIGHT);
	    self.table.tableHeaderView = tableViewHeader;
	    
	    
	    
	    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AcapellaPrefs.bundle"];
	    
	    if (bundle){
	    	self.acapellaPrefsHeaderView = [[SWAcapellaPrefsHeaderView alloc] initWithImage:[UIImage
	    																imageWithContentsOfFile:[bundle
	    																	pathForResource:@"Acapella_Prefs_Banner_Background" ofType:@"png"]]];
	    	self.acapellaPrefsHeaderView.frame = tableViewHeader.frame;
			[self.table.superview insertSubview:self.acapellaPrefsHeaderView belowSubview:self.table];
	    }
	
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        
        self.packageDEB = [PIDebianPackage packageForFile:@"/Library/PreferenceBundles/AcapellaPrefs.bundle"];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            PSSpecifier *spec = [self specifierForID:@"Version"];
            if (spec){
                [self reloadSpecifier:spec animated:YES];
            }
            
        });
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self scrollViewDidScroll:self.table]; //update our stretch header so it is in correct position
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.acapellaPrefsHeaderView){
        [self.acapellaPrefsHeaderView removeFromSuperview];
        self.acapellaPrefsHeaderView = nil;
    }
    
    self.packageDEB = nil;
}

#pragma mark UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (self.acapellaPrefsHeaderView && self.table == scrollView){
	
		CGFloat delta = 0.0f;
	   	CGRect stretchedFrame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, SW_ACAPELLA_HEADER_HEIGHT);
    
	   	delta = fabsf(MIN(0.0f, self.table.contentOffset.y));
    
	   	if (self.table.contentOffset.y > 0.0f){
        	stretchedFrame.origin.y -= self.table.contentOffset.y;
		}
    
		stretchedFrame.size.height += delta;
	   	self.acapellaPrefsHeaderView.frame = stretchedFrame;
	}
}

#pragma mark Tutorial Video

- (void)viewTutorialVideo:(PSSpecifier *)specifier
{
    //random string so php doesnt cache
    NSInteger randomStringLength = 200;
    NSMutableString *randomString = [NSMutableString stringWithCapacity:randomStringLength];
    for (int i = 0; i < randomStringLength; i++){
        [randomString appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",
                     @"http://sluthware.com/SluthwareApps/SWAcapellaTutorialVideoURL.php?",
                     randomString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
                                if (connectionError){
                                    //NSLog(@"SW Error - %@", connectionError);
                                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Could not retrive Video URL"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil] show];
                                } else {
                                    NSString *result = [[NSString alloc] initWithData:data
                                                                             encoding:NSUTF8StringEncoding];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result]];
                                }
                           }];
}

#pragma mark Twitter

- (void)viewTwitterProfile:(PSSpecifier *)specifier
{
	if (!specifier.properties[@"username"]){
		return;
	}
	
	NSURL *tweetbotURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"tweetbot:///user_profile/", specifier.properties[@"username"]]];
    NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"twitter://user?screen_name=", specifier.properties[@"username"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:tweetbotURL]){
        [[UIApplication sharedApplication] openURL:tweetbotURL];
        return;
    } else if ([[UIApplication sharedApplication] canOpenURL:twitterURL]){
        [[UIApplication sharedApplication] openURL:twitterURL];
        return;
    }
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://twitter.com/", specifier.properties[@"username"]]]];
}

#pragma mark Helper

- (id)getVersionNumberForSpecifier:(PSSpecifier *)specifier
{
    if (self.packageDEB){
        return self.packageDEB.version;
    }
    
    return @"...";
}

- (void)_returnKeyPressed:(id)pressed
{
    [super _returnKeyPressed:pressed];
    
    //this will dismiss the keyboard and save the preferences for the selected text field
    if ([self isKindOfClass:[UIViewController class]]){
        [((UIViewController *)self).view endEditing:YES];
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSDictionary *acapellaPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.patsluth.AcapellaPrefs.plist"];
	
	if (!acapellaPrefs[specifier.properties[@"key"]]){
		if (acapellaPrefs[specifier.properties[@"placeholder"]]){
			return specifier.properties[@"placeholder"];
		}
		
		return specifier.properties[@"default"];
	}
	
	return acapellaPrefs[specifier.properties[@"key"]];
}
 
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.patsluth.AcapellaPrefs.plist"]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:@"/User/Library/Preferences/com.patsluth.AcapellaPrefs.plist" atomically:YES];
	CFStringRef mikotoPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), mikotoPost, NULL, NULL, YES);
}

- (void)dealloc
{
	dlclose(handle);
}

@end




