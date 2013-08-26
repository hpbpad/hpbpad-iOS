#import "WPAddCategoryViewController.h"
#import "EditSiteViewController.h"
#import "WordPressAppDelegate.h"
#import "UIBarButtonItem+Styled.h"

// categoryではなく、termを新規追加するViewControllerにする。

@implementation WPAddCategoryViewController
@synthesize blog;
@synthesize postType;

#pragma mark -
#pragma mark LifeCycle Methods

- (void)viewDidLoad {
    [FileLogger log:@"%@ %@", self, NSStringFromSelector(_cmd)];
	[super viewDidLoad];
    catTableView.sectionFooterHeight = 0.0;
    
    saveButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save button label (saving content, ex: Post, Page, Comment, Category).") style:UIBarButtonItemStyleDone target:self action:@selector(saveAddCategory:)];
    
    newCatNameField.font = [UIFont fontWithName:@"Helvetica" size:17];
    parentCatNameField.font = [UIFont fontWithName:@"Helvetica" size:17];
    parentCatNameLabel.text = NSLocalizedString(@"Parent Category", @"Placeholder to set a parent category for a new category.");
    parentCatNameField.placeholder = NSLocalizedString(@"Optional", @"Placeholder to indicate that filling out the field is optional.");
    
    [self setTaxonomyWithObject:[[self.blog taxonomiesOfPostType:self.postType] objectAtIndex:0]];
    taxonomyNameField.font = [UIFont fontWithName:@"Helvetica" size:17];
    taxonomyNameLabel.text = @"タクソノミー";
    taxonomyNameField.text = [[taxonomy valueForKey:@"taxonomy"] valueForKey:@"label"];
    
    cancelButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button label.");

    parentCat = nil;
    //Set background to clear for iOS 4. Delete this line when we set iOS 5 as the min OS
    catTableView.backgroundColor = [UIColor clearColor];
    taxonomyTableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_bg"]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = NSLocalizedString(@"Add Category", @"Button to add category.");
	// only show "cancel" button if we're presented in a modal view controller
	// that is, if we are the root item of a UINavigationController
	if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *parent = (UINavigationController *)self.parentViewController;
		if ([[parent viewControllers] objectAtIndex:0] == self) {
			self.navigationItem.leftBarButtonItem = cancelButtonItem;
        } else {
            if (IS_IPAD) {
                if ([[parent viewControllers] objectAtIndex:1] == self)
                    self.navigationItem.leftBarButtonItem = cancelButtonItem;
            } else {
                if ([[parent viewControllers] objectAtIndex:0] == self) {
                    self.navigationItem.leftBarButtonItem = cancelButtonItem;
                }
            }

        }
	}
    self.navigationItem.rightBarButtonItem = saveButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    WPLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


#pragma mark -
#pragma mark Instance Methods

- (void)clearUI {
    newCatNameField.text = @"";
    parentCatNameField.text = @"";
}

- (void)addProgressIndicator {
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *activityButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aiv];
	activityButtonItem.title = @"foobar!";
    [aiv startAnimating];
    
    self.navigationItem.rightBarButtonItem = activityButtonItem;
}

- (void)removeProgressIndicator {
	self.navigationItem.rightBarButtonItem = saveButtonItem;
	
}
- (void)dismiss {
    WPFLogMethod();
    if (IS_IPAD == YES) {
        [(WPSelectionTableViewController *)self.parentViewController popViewControllerAnimated:YES];
    } else {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)cancelAddCategory:(id)sender {
    [self clearUI];
    [self dismiss];
}

- (IBAction)saveAddCategory:(id)sender {
    NSString *catName = newCatNameField.text;
    
    if (!catName ||[catName length] == 0) {
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Category title missing.", @"Error popup title to indicate that there was no category title filled in.")
                                                         message:NSLocalizedString(@"Title for a category is mandatory.", @"Error popup message to indicate that there was no category title filled in.")
                                                        delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        
        [alert2 show];
        WordPressAppDelegate *delegate = (WordPressAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate setAlertRunning:YES];
        
        return;
    }
    
    //if ([Category existsName:catName forBlog:self.blog withParentId:parentCat.categoryID]) {
    if ([Term existsName:catName forBlog:self.blog withParentId:parentCat.termID taxonomy:taxonomy.name]) {
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Category name already exists.", @"Error popup title to show that a category already exists.")
                                                         message:NSLocalizedString(@"There is another category with that name.", @"Error popup message to show that a category already exists.")
                                                        delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button label.") otherButtonTitles:nil];
		
        [alert2 show];
        WordPressAppDelegate *delegate = (WordPressAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate setAlertRunning:YES];
        
        return;
    }
    
    [self addProgressIndicator];
    
    //[Category createCategory:catName parent:parentCat forBlog:self.blog success:^(Category *category) {
    [Term createTerm:catName parent:parentCat taxonomy:taxonomy.name forBlog:self.blog success:^(Term *term) {
        //re-syncs categories this is necessary because the server can change the name of the category!!!
		//[self.blog syncCategoriesWithSuccess:nil failure:nil];
        /* [[NSNotificationCenter defaultCenter] postNotificationName:WPNewCategoryCreatedAndUpdatedInBlogNotificationName
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObject:category forKey:@"category"]]; */
        
        void (^successBlock)() = ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:WPNewTermCreatedAndUpdatedInBlogNotificationName
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:term forKey:@"term"]];
        };
		[taxonomy syncTermsWithSuccess:successBlock failure:nil];
        
        [self clearUI];
        [self removeProgressIndicator];
        [self dismiss];
    } failure:^(NSError *error) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		[self removeProgressIndicator];
		
		if ([error code] == 403) {

			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't Connect", @"")
																message:NSLocalizedString(@"The username or password stored in the app may be out of date. Please re-enter your password in the settings and try again.", @"")
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
			[alertView show];
			
			// bad login/pass combination
			EditSiteViewController *editSiteViewController = [[EditSiteViewController alloc] initWithNibName:nil bundle:nil];
			editSiteViewController.blog = self.blog;
			[self.navigationController pushViewController:editSiteViewController animated:YES];
			
		} else {
			NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.blog, @"currentBlog", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:kXML_RPC_ERROR_OCCURS object:error userInfo:errInfo];
		}
    }];
}


#pragma mark - functionalmethods

- (void)selectionTableViewController:(WPSelectionTableViewController *)selctionController completedSelectionsWithContext:(void *)selContext selectedObjects:(NSArray *)selectedObjects haveChanges:(BOOL)isChanged {
    if (!isChanged) {
        [selctionController clean];
        return;
    }

    if (selContext == kParentCategoriesContext) {
        //Category *curCat = [selectedObjects lastObject];
        id curCat = [selectedObjects lastObject];
        
        if (parentCat) {
            parentCat = nil;
        }

        /*
         if (curCat) {
            parentCat = curCat;
            parentCatNameField.text = curCat.categoryName;
            [catTableView reloadData];
        }
         */
        if (curCat) {
            if ([curCat isKindOfClass:[Taxonomy class]]) {
                // taxonomyを選択した時
                [self setTaxonomyWithObject:curCat];
                [catTableView reloadData];
            } else {
                // termを選択した時
                parentCat = curCat;
                parentCatNameField.text = parentCat.name;
                [catTableView reloadData];
            }
        }
    }

    [selctionController clean];
}

- (void)populateSelectionsControllerWithTaxonomies {
    //WPSelectionTableViewController *selectionTableViewController = [[WPSegmentedSelectionTableViewController alloc] initWithNibName:@"WPSelectionTableViewController" bundle:nil];
    TaxonomiesSelectionTableViewController *selectionTableViewController = [[TaxonomiesSelectionTableViewController alloc] initWithNibName:@"WPSelectionTableViewController" bundle:nil];
    
    NSArray *selObjs = [NSArray array];
    
	NSArray *taxonomies = [self.blog taxonomiesOfPostType:self.postType];
	
	[selectionTableViewController populateDataSource:taxonomies
     havingContext:kParentCategoriesContext
     selectedObjects:selObjs
     selectionType:kRadio
     andDelegate:self];

    selectionTableViewController.title = @"タクソノミー";
    
    [self.navigationController pushViewController:selectionTableViewController animated:YES];
}

- (void)populateSelectionsControllerWithCategories {
    //WPSelectionTableViewController *selectionTableViewController = [[WPSegmentedSelectionTableViewController alloc] initWithNibName:@"WPSelectionTableViewController" bundle:nil];
    TermsSelectionTableViewController *selectionTableViewController = [[TermsSelectionTableViewController alloc] initWithNibName:@"WPSelectionTableViewController" bundle:nil];
    
    //NSArray *selObjs = ((parentCat == nil) ? [NSArray array] : [NSArray arrayWithObject:parentCat]);
    NSArray *selObjs = [NSArray array];
    
    if (taxonomy == nil) {
        [self setTaxonomyWithObject:[[self.blog taxonomiesOfPostType:self.postType] objectAtIndex:0]];
    }
	//NSArray *cats = [self.blog sortedCategories];
    NSArray *taxonomies = [NSArray arrayWithObject:taxonomy];
    
    if([[taxonomies valueForKeyPath:@"terms"] count] < 1){
        // termsが0個なら以下を行わない。
        return;
    }
	
	[selectionTableViewController populateDataSource:taxonomies
     havingContext:kParentCategoriesContext
     selectedObjects:selObjs
     selectionType:kRadio
     andDelegate:self];

    selectionTableViewController.title = NSLocalizedString(@"Parent Category", @"");

    [self.navigationController pushViewController:selectionTableViewController animated:YES];
}

#pragma mark - tableviewDelegates/datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return newCatNameCell;
    } else if (indexPath.section == 1) {
        return taxonomyNameCell;
    } else {
//		parentCatNameCell.text = @"Parent Category";
//		parentCatNameCell.textColor = [UIColor blueColor];
        return parentCatNameCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

    if (indexPath.section == 1) {
        [self populateSelectionsControllerWithTaxonomies];
    } else if (indexPath.section == 2) {
        [self populateSelectionsControllerWithCategories]; // Terms
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark textfied deletage

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WordPressAppDelegate *delegate = (WordPressAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate setAlertRunning:NO];
}

#pragma mark -
#pragma mark Utils
- (void)setTaxonomyWithObject:(Taxonomy *)_taxonomy {
    taxonomy = _taxonomy;
    taxonomyNameField.text = [[taxonomy valueForKey:@"taxonomy"] valueForKey:@"label"];
    
    // termが一つも無い場合も、「親カテゴリー」欄を隠す。 
    if([taxonomy.terms count] > 0 && [[taxonomy.taxonomy valueForKey:@"hierarchical"] boolValue]){
        [parentCatNameCell setHidden:NO];
    } else {
        parentCatNameCell.textLabel.text = @"";
        [parentCatNameCell setHidden:YES];
    }
}

@end
