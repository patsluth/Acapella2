
#import "SWAcapellaShowEEActivity.h"

@implementation SWAcapellaShowEEActivity

- (void)performActivity
{
    [self activityDidFinish:YES];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (NSString *)activityType
{
    return SWAcapellaShowEEActivityType;
}

- (NSString *)activityTitle
{
    return @"Equalizer Everywhere";
}

- (UIImage *)activityImage
{
    UIImage *returnVal;
    
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/AcapellaSupport.bundle"];
    
    if (bundle){
        returnVal = [UIImage
                     imageWithContentsOfFile:[bundle
                                              pathForResource:@"Acapella_Activity_EE" ofType:@"png"]];
    }
    
    return returnVal;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *)activityViewController
{
    return nil;
}

@end




