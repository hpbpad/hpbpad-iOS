//
//  ThumbnailPagerView.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/30.
//

#import <UIKit/UIKit.h>
#import "Blog.h"
#import "SidebarViewController.h"
#import "PostTypePagerView.h"
#import "TopMenuViewController.h"
@class TopMenuViewController;

@interface ThumbnailPagerView : UIScrollView

@property (nonatomic) NSArray* items;
@property (nonatomic) NSInteger currentPosition;
@property (nonatomic) TopMenuViewController* topMenuViewController;
@property (nonatomic) UIPageControl* pageControl;
//@property (nonatomic) SidebarViewController* sidebarViewController;
//@property (nonatomic) PostTypePagerView* postTypePagerView;

- (void)reset;
- (void)update;

@end
