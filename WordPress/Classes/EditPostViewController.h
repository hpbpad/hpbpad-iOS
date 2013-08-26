#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WPKeyboardToolbar.h"
#import "Taxonomy.h"

#define kSelectionsStatusContext ((void *)1000)
#define kSelectionsCategoriesContext ((void *)2000)

@class AbstractPost;

typedef NS_ENUM(NSUInteger, EditPostViewControllerMode) {
	EditPostViewControllerModeNewPost,
	EditPostViewControllerModeEditPost
};

@interface EditPostViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate,WPKeyboardToolbarDelegate>

@property(nonatomic, strong) NSString *statsPrefix;

- (id)initWithPost:(AbstractPost *)aPost;
@end
