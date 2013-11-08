//
//  PostSEOViewController.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/08/30.
//

#import <UIKit/UIKit.h>
#import "EditPostViewController.h"
#import "PostSEOBalloonView.h"
#import "PanelNavigationConstants.h"

@interface PostSEOViewController : UIViewController {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *titleContainer;
    IBOutlet UIView *titleLabelWrap;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIView *keywordsChartContainer;
    //IBOutlet UIView *keywordsChartLabelWrap;
    IBOutlet UILabel *keywordsChartLabel;
    IBOutlet UIView *keywordsChartView;
    IBOutlet UIView *contentsContainer;
    IBOutlet UIView *contentsLabelWrap;
    IBOutlet UILabel *contentsLabel;
    IBOutlet UIView *errorMessageView;
    IBOutlet UILabel *errorMessageLabel;
    IBOutlet PostSEOBalloonView *titleBalloonView;
    IBOutlet PostSEOBalloonView *keywordsChartBalloonView;
    IBOutlet PostSEOBalloonView *contentsBalloonView;
    UIActivityIndicatorView *indicator;
}

- (id)initWithPost:(AbstractPost *)aPost;
- (void)notifyRotatedViewFrame:(CGRect)viewFrame;

@property (nonatomic, weak) EditPostViewController *postDetailViewController;

@end
