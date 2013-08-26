//
//  SidebarViewController.h
//  WordPress
//
//  Created by Jorge Bernal on 5/21/12.
//  Copyright (c) 2012 WordPress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarSectionHeaderView.h"

@class Post;

@interface SidebarViewController : UIViewController <UIActionSheetDelegate, SidebarSectionHeaderViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *settingsButton;
    IBOutlet UIView *utililtyView;
    NSUInteger openSectionIdx;
    NSIndexPath *currentIndexPath;
    BOOL restoringView;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
@property (nonatomic, strong) IBOutlet UIView *utililtyView;
@property (nonatomic, weak) SectionInfo *openSection;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSMutableArray *sectionInfoArray;

- (IBAction)showSettings:(id)sender;
- (void)processRowSelectionAtIndexPath:(NSIndexPath *)indexPath;
- (void)processRowSelectionAtIndexPath:(NSIndexPath *)indexPath closingSidebar:(BOOL)closingSidebar;
- (void)showCommentWithId:(NSNumber *)itemId blogId:(NSNumber *)blogId;
- (void)showTopMenu;
- (void)selectNotificationsRow;

- (void)uploadQuickPhoto:(Post *)post;
- (void)restorePreservedSelection;
- (void)didReceiveUnseenNotesNotification;

- (void)showQuickPhoto:(UIImagePickerControllerSourceType)sourceType useCameraPlus:(BOOL)useCameraPlus withImage:(UIImage *)image;
- (NSArray *)blogs;
    
@end
