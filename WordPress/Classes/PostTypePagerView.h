//
//  PostTypePagerView.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/30.
//

#import <UIKit/UIKit.h>
#import "PostType.h"
#import <QuartzCore/QuartzCore.h>

@interface PostTypePagerView : UIScrollView

@property (nonatomic) NSArray* items;
@property (nonatomic) NSInteger currentPosition;

- (void)reset;
- (void)update;

@end
