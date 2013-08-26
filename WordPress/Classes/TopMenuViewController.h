//
//  TopMenuViewController.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/06/26.
//

#import <UIKit/UIKit.h>
#import "CameraPlusPickerManager.h"
#import "PostsViewController.h"
#import "PanelNavigationConstants.h"
#import "SidebarViewController.h"
#import "WPWebViewController.h"
#import "PostTypePagerView.h"
#import "ThumbnailPagerView.h"
@class ThumbnailPagerView;

@interface TopMenuViewController : UIViewController{
    UIView *view;
}

@property (nonatomic, strong) IBOutlet UIView *overView;
@property (nonatomic, strong) IBOutlet UIView *overViewPanHandle;
@property (nonatomic, strong) IBOutlet UIImageView *overViewPanHandleImage;
@property (nonatomic, strong) IBOutlet UIImageView *titleImageView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) IBOutlet UIView *transparentBGView;
@property (nonatomic, strong) IBOutlet ThumbnailPagerView *thumbnailPagerView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet PostTypePagerView *postTypePagerView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *barButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail1;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail2;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail3;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail4;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapBlogThumbnailRecognizer;
@property (nonatomic) NSInteger webViewLoadingCount;

- (IBAction)onTouchUpPostButton:(UIButton *)sender;
- (IBAction)onTouchUpPhotoButton:(UIButton *)sender;
- (IBAction)onTouchUpListButton:(UIButton *)sender;
- (IBAction)onTapThumbnail1:(UITapGestureRecognizer *)sender;
- (IBAction)onTapThumbnail2:(UITapGestureRecognizer *)sender;
- (IBAction)onTapthumbnail3:(UITapGestureRecognizer *)sender;
- (IBAction)onTapThumbnail4:(UITapGestureRecognizer *)sender;

- (NSArray *)postTypes;
- (void)showPreview;
- (void)updateLayout;

@end
