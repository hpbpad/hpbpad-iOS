#import <UIKit/UIKit.h>
#import "WPSegmentedSelectionTableViewController.h"
#import "TermsSelectionTableViewController.h"
#import "TaxonomiesSelectionTableViewController.h"
//#import "Category.h"
#import "Term.h"
#import "Taxonomy.h"
#import "Blog.h"

#define kParentCategoriesContext ((void *)999)

@interface WPAddCategoryViewController : UIViewController {
    IBOutlet UITableView *catTableView;
    IBOutlet UITableView *taxonomyTableView;
    
    IBOutlet UITextField *newCatNameField;
    IBOutlet UITextField *parentCatNameField;
    IBOutlet UILabel *parentCatNameLabel;
    IBOutlet UITextField *taxonomyNameField;
    IBOutlet UILabel *taxonomyNameLabel;
    
    IBOutlet UITableViewCell *newCatNameCell;
    IBOutlet UITableViewCell *parentCatNameCell;
    IBOutlet UITableViewCell *taxonomyNameCell;
    
    IBOutlet UIBarButtonItem *saveButtonItem;
    IBOutlet UIBarButtonItem *cancelButtonItem;

    //Category *parentCat;
    Term *parentCat;
    Taxonomy *taxonomy;
}
@property (nonatomic, strong) Blog *blog;
@property (nonatomic, strong) NSString *postType;

- (IBAction)cancelAddCategory:(id)sender;
- (IBAction)saveAddCategory:(id)sender;
- (void)removeProgressIndicator;

@end
