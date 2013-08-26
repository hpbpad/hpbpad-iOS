//
//  TaxonomiesSelectionTableViewController.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/10.
//

#import "TaxonomiesSelectionTableViewController.h"

#import "WordPressAppDelegate.h"
#import "Taxonomy.h"
#import "NSString+XMLExtensions.h"

@implementation TaxonomiesSelectionTableViewController

#pragma mark -
#pragma mark Instance Methods

- (void)populateDataSource:(NSArray *)sourceObjects havingContext:(void *)context selectedObjects:(NSArray *)selObjects selectionType:(WPSelectionType)aType andDelegate:(id)delegate {
    objects = sourceObjects;
    curContext = context;
    selectionType = aType;
    selectionDelegate = delegate;

    int i = 0, count = [objects count];
    selectionStatusOfObjects = [NSMutableArray arrayWithCapacity:count];

    for (i = 0; i < count; i++) {
        [selectionStatusOfObjects addObject:[NSNumber numberWithBool:[selObjects containsObject:[sourceObjects objectAtIndex:i]]]];
    }

    originalSelObjects = [selectionStatusOfObjects copy];

    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectionTableRowCell = @"selectionTableRowCell";

    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:selectionTableRowCell];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectionTableRowCell];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }

    //cell.textLabel.text = [[objects objectAtIndex:indexPath.row] name];
    Taxonomy *tax = [objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [[tax valueForKey:@"taxonomy"] valueForKey:@"label"];
    
    BOOL curStatus = [[selectionStatusOfObjects objectAtIndex:indexPath.row] boolValue];
    cell.textLabel.textColor = (curStatus == YES ? [UIColor blueColor] : [UIColor blackColor]);
    cell.accessoryType = (UITableViewCellAccessoryType)([[selectionStatusOfObjects objectAtIndex:indexPath.row] boolValue] == YES ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

    return cell;
}

@end
