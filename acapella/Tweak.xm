#import <AcapellaKit/AcapellaKit.h>

%ctor
{
NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
[bundle load];

    SWAcapellaBase *base = [[%c(SWAcapellaBase) alloc] init];
    [base testMethod];
}