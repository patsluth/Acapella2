//
//  SWAPSContextualActionsPSViewController.mm
//  AcapellaPrefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import <Preferences/Preferences.h>





@interface SWAPSContextualActionsPSViewController : PSEditableListController
{
}

@property (strong, nonatomic ) NSMutableDictionary *currentValue;

@end





@implementation SWAPSContextualActionsPSViewController

- (id)specifiers
{
    if (!_specifiers) {
        
        NSMutableArray *celloSpecifiers = [@[] mutableCopy];
        
        self.currentValue = [[self.specifier.properties valueForKey:@"value"] mutableCopy];
        NSArray *enabledActions = [self.currentValue valueForKey:@"enabled"];
        NSArray *disabledActions = [self.currentValue valueForKey:@"disabled"];
        
        // Enabled options
        PSSpecifier *enabledGroup = [PSSpecifier groupSpecifierWithName:@"enabled"];
        [celloSpecifiers addObject:enabledGroup];
        
        for (NSDictionary *action in enabledActions) {
            
            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:[action valueForKey:@"title"]
                                                               target:self
                                                                  set:NULL
                                                                  get:NULL
                                                               detail:Nil
                                                                 cell:PSTitleValueCell
                                                                 edit:Nil];
            spec.identifier = [action valueForKey:@"key"];
            [celloSpecifiers addObject:spec];
            
        }
        
        // Disabled options
        PSSpecifier *disabledGroup = [PSSpecifier groupSpecifierWithName:@"disabled"];
        [celloSpecifiers addObject:disabledGroup];
        
        for (NSDictionary *action in disabledActions) {
            
            PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:[action valueForKey:@"title"]
                                                               target:self
                                                                  set:NULL
                                                                  get:NULL
                                                               detail:Nil
                                                                 cell:PSTitleValueCell
                                                                 edit:Nil];
            spec.identifier = [action valueForKey:@"key"];
            [celloSpecifiers addObject:spec];
            
        }
        
        _specifiers = [celloSpecifiers copy];
    }
    
    return _specifiers;
}

#pragma mark - UITableView

- (void)editDoneTapped
{
    [super editDoneTapped];
    
    NSString *key = [self.specifier.properties valueForKey:@"key"];
    NSString *defaults = [self.specifier.properties valueForKey:@"defaults"];
    
    //update the CFPreferences so we can read them right away
    CFPreferencesSetAppValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)self.currentValue, (__bridge CFStringRef)defaults);
    CFPreferencesAppSynchronize((__bridge CFStringRef)defaults);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *enabledActions = [[self.currentValue valueForKey:@"enabled"] mutableCopy];
    NSMutableArray *disabledActions = [[self.currentValue valueForKey:@"disabled"] mutableCopy];
    
    // Get references to source and destination arrays
    NSMutableArray *sourceArray = (sourceIndexPath.section == 0) ? enabledActions : disabledActions;
    NSMutableArray *destinationArray = (destinationIndexPath.section == 0) ? enabledActions : disabledActions;
    
    // Move our value to the correct position in our destination array
    id sourceValue = [sourceArray objectAtIndex:sourceIndexPath.row];
    [sourceArray removeObject:sourceValue];
    [destinationArray insertObject:sourceValue atIndex:destinationIndexPath.row];
    
    // Update our data source
    [self.currentValue setValue:[enabledActions copy] forKey:@"enabled"];
    [self.currentValue setValue:[disabledActions copy] forKey:@"disabled"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        cell.showsReorderControl = YES;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end




