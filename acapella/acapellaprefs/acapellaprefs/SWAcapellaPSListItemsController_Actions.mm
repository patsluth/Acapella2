//
//  SWAcapellaPSListItemsController_Actions.m
//  acapellaprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>





@interface SWAcapellaPSListItemsController_Actions : PSListItemsController
{
}

@end





@implementation SWAcapellaPSListItemsController_Actions

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2
{
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    if (cell && self.bundle){
        NSString *imagePath = [self.bundle pathForResource:[cell.specifier.name stringByReplacingOccurrencesOfString:@" "
                                                                                                          withString:@""] ofType:@"png"];
        cell.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return cell;
}


@end




