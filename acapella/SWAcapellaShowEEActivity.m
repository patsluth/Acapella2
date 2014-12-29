
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
    return nil;
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




