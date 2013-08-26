//
//  TermsSelectionTableViewController.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/10.
//

#import "TermsSelectionTableViewController.h"

#import "WPSegmentedSelectionTableViewController.h"
#import "WPCategoryTree.h"
#import "Term.h"
#import "NSString+XMLExtensions.h"

@interface NSObject (WPSelectionTableViewControllerDelegateCategory)

- (void)selectionTableViewController:(WPSelectionTableViewController *)selctionController completedSelectionsWithContext:(void *)selContext selectedObjects:(NSArray *)selectedObjects haveChanges:(BOOL)isChanged;
@end

@interface TermsSelectionTableViewController (private)
- (int)indentationLevelForCategory:(NSNumber *)categoryParentID categoryCollection:(NSMutableDictionary *)categoryDict;
@end


@implementation TermsSelectionTableViewController
@synthesize taxonomies;

#pragma mark -
#pragma mark Instance Methods

- (void)handleNewTerm:(NSNotification *)notification {
    Term *newTerm = [[notification userInfo] objectForKey:@"term"];
    
    // If a new category was just added mark it selected by default.
    if ([self.objects containsObject:newTerm]) {
        NSUInteger idx = [self.objects indexOfObject:newTerm];
        
        NSIndexPath *indexPath = [self indexPathOfPositionInObjects:idx];
        [[selectionStatusOfObjects objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }
}

- (BOOL)haveChanges {
    int i = 0, j = 0, sectionCount = [self.taxonomies count];
    id s, o;
    
    for (i = 0; i < sectionCount; i++) {
        for (j = 0; j < [[[self.taxonomies objectAtIndex:i] valueForKey:@"terms"] count]; j++) {
            s = [[self.selectionStatusOfObjects objectAtIndex:i] objectAtIndex:j];
            o = [[self.originalSelObjects objectAtIndex:i] objectAtIndex:j];
            if(![s isEqual:o]){
                return YES;
            }
        }
    }
    return NO;
}

//overriding the main Method
- (void)populateDataSource:(NSArray *)sourceObjects havingContext:(void *)context selectedObjects:(NSArray *)selObjects selectionType:(WPSelectionType)aType andDelegate:(id)delegate {
    curContext = context;
    selectionType = aType;
    selectionDelegate = delegate;

    WPCategoryTree *tree = [[WPCategoryTree alloc] initWithParent:nil];
    
    self.taxonomies = sourceObjects;
    //self.taxonomies = [sourceObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name != %@",@"post_tag"]];
    
    NSMutableArray *array = [NSMutableArray array];
    //NSArray *terms;
    for (NSArray *terms in [self.taxonomies valueForKeyPath:@"terms"]) {
        if([terms count] < 1) { continue; }
        [array addObjectsFromArray:terms];
    }
    [tree getChildrenFromObjects:array];
    
    
    self.objects = [tree getAllObjects];

    int i = 0, k = 0, count = [self.objects count];
    NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] init];
    
    self.selectionStatusOfObjects = [[NSMutableArray alloc] init];
    for (i = 0; i < [self.taxonomies count]; i++) {
        [self.selectionStatusOfObjects addObject:[[NSMutableArray alloc] init]];
    }
    
    [categoryIndentationLevelsDict removeAllObjects];

    for (i = 0; i < count; i++) {
        Term *term = [objects objectAtIndex:i];
        [categoryDict setObject:term forKey:term.termID];
        NSUInteger indexInTaxonomies = [[self.taxonomies valueForKeyPath:@"name"] indexOfObject:term.taxonomy];
        
        BOOL isFound = NO;

        for (k = 0; k <[selObjects count]; k++) {
            if ( [[[selObjects objectAtIndex:k] valueForKey:@"termID"] isEqual:term.termID]) {
                [[selectionStatusOfObjects objectAtIndex:indexInTaxonomies] addObject:[NSNumber numberWithBool:YES]];
                isFound = YES;
                break;
            }
        }

        if (!isFound)
            [[selectionStatusOfObjects objectAtIndex:indexInTaxonomies] addObject:[NSNumber numberWithBool:NO]];
        
        int indentationLevel = [self indentationLevelForCategory:term.parent categoryCollection:categoryDict];
        [categoryIndentationLevelsDict setValue:[NSNumber numberWithInt:indentationLevel]
                                         forKey:[term.termID stringValue]];
    }

    self.originalSelObjects = [[NSMutableArray alloc] init];
    for (NSArray *array in self.selectionStatusOfObjects) {
        [self.originalSelObjects addObject:[array copy]];
    }
    
    [tableView reloadData];
}

- (int)indentationLevelForCategory:(NSNumber *)parentID categoryCollection:(NSMutableDictionary *)categoryDict {
    if ([parentID intValue] == 0) {
        return 0;
    } else {
        Term *term = [categoryDict objectForKey:parentID];
        return ([self indentationLevelForCategory:term.parent categoryCollection:categoryDict]) + 1;
    }
}

#pragma mark TableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return [self.taxonomies count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.taxonomies objectAtIndex:section] valueForKey:@"terms"] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectionTableRowCell = @"selectionTableRowCell";

    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:selectionTableRowCell];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectionTableRowCell];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }

    NSInteger index = [self positionInObjectsOfIndexPath:indexPath];
    Term *term = [self.objects objectAtIndex:index];
    
    int indentationLevel = [[categoryIndentationLevelsDict valueForKey:[term.termID stringValue]] intValue];
    cell.indentationLevel = indentationLevel;

    if (indentationLevel == 0) {
        cell.imageView.image = nil;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"category_child.png"];
    }

    cell.textLabel.text = [[term valueForKey:@"name"] stringByDecodingXMLCharacters];
    
    BOOL curStatus = [[[selectionStatusOfObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] boolValue];
    if (curStatus) {
        cell.textLabel.textColor = rowTextColor;
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }

    cell.accessoryType = [self accessoryTypeForRowWithIndexPath:indexPath ofTableView:tableView];
    return cell;
}

#pragma mark TableView Delegate Methods

- (UITableViewCellAccessoryType)accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath ofTableView:(UITableView *)aTableView {
    int previousRows = indexPath.section + indexPath.row;
    int currentSection = indexPath.section;

    while (currentSection > 0) {
        currentSection--;
        previousRows += [self tableView:aTableView numberOfRowsInSection:currentSection] - 1;
    }

    //return (UITableViewCellAccessoryType)([[selectionStatusOfObjects objectAtIndex:previousRows] boolValue] == YES ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return (UITableViewCellAccessoryType)([[[selectionStatusOfObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] boolValue] == YES ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 38.0;
    return height;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 30.0;
    [aTableView setSectionHeaderHeight:height];
    return height;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    if( [[[self.taxonomies objectAtIndex:section] valueForKey:@"terms"] count] < 1 ) { return nil; };
    return [[[self.taxonomies objectAtIndex:section] valueForKey:@"taxonomy"] valueForKey:@"label"];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 5.5;
    [aTableView setSectionFooterHeight:height];
    return height;
}

- (NSArray *)selectedObjects {
    int i = 0, j = 0, n = 0, count = [self.objects count], sectionCount = [self.taxonomies count];
    
    NSMutableArray *selectionObjects = [NSMutableArray arrayWithCapacity:count];
    id curObject = nil;
    
    for (i = 0; i < sectionCount; i++) {
        for (j = 0; j < [[[self.taxonomies objectAtIndex:i] valueForKey:@"terms"] count]; j++) {
            if( j > [[self.selectionStatusOfObjects objectAtIndex:i] count] - 1 ) { break; };
            curObject = [self.objects objectAtIndex:n];
            if ([[[self.selectionStatusOfObjects objectAtIndex:i] objectAtIndex:j] boolValue] == YES ){
                [selectionObjects addObject:curObject];
            }
            n++;
        }
    }
    return selectionObjects;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL curStatus = [[[selectionStatusOfObjects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] boolValue];

    if (selectionType == kCheckbox) {
        [[selectionStatusOfObjects objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!curStatus]];
        
        [aTableView reloadData];
    } else { //kRadio
        if (curStatus == NO) {
            int index = [[selectionStatusOfObjects objectAtIndex:indexPath.section] indexOfObject:[NSNumber numberWithBool:YES]];
            [[selectionStatusOfObjects objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];

            if (index >= 0 && index <[[selectionStatusOfObjects objectAtIndex:indexPath.section] count])
                [[selectionStatusOfObjects objectAtIndex:indexPath.section] replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];

            [aTableView reloadData];

            if (autoReturnInRadioSelectMode) {
                [self performSelector:@selector(gotoPreviousScreen) withObject:nil afterDelay:0.2f inModes:[NSArray arrayWithObject:[[NSRunLoop currentRunLoop] currentMode]]];
            }
        }
    }
    [aTableView deselectRowAtIndexPath:[aTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark Utils

// indexPath(table中での位置 = taxonomies中での位置) から、objects中での位置を取得
- (NSIndexPath *) indexPathOfPositionInObjects:(NSInteger)index {
    Term *term = [self.objects objectAtIndex:index];
    NSArray *taxonomyNames = [self.taxonomies valueForKey:@"name"];
    NSInteger section = [taxonomyNames indexOfObject:term.taxonomy];
    NSInteger row = index;
    if( section > 0 ){
        for ( NSInteger i = 0; i < (int)section; i++ ) {
            row -= [[[self.taxonomies objectAtIndex:i] valueForKey:@"terms"] count];
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}

// objects中での位置 から、 indexPath(table中での位置 = taxonomies中での位置) を取得
- (NSInteger) positionInObjectsOfIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if( indexPath.section > 0 ){
        for ( NSInteger i =0; i < indexPath.section; i++ ) {
            index += [[[self.taxonomies objectAtIndex:i] valueForKey:@"terms"] count];
        }
    }
    return index;
}

@end
