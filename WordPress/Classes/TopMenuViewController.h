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
@property (strong, nonatomic) IBOutlet UIImageView *mpLogoView;
@property (nonatomic, strong) IBOutlet ThumbnailPagerView *thumbnailPagerView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet PostTypePagerView *postTypePagerView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapBlogThumbnailRecognizer;
@property (nonatomic) NSInteger webViewLoadingCount;
@property (strong, nonatomic) UIButton *downButton;

- (IBAction)onTouchUpPostButton:(UIButton *)sender;
- (IBAction)onTouchUpPhotoButton:(UIButton *)sender;
- (IBAction)onTouchUpListButton:(UIButton *)sender;

- (NSArray *)postTypes;
- (void)showPreview;
- (void)updateLayout;

@end
