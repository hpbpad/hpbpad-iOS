//
//  PostSEOBalloonView.h
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/09/11.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PostSEOBalloonView : UIView

@property (nonatomic, strong) NSString *text;

- (void)makeBalloon;
- (void)setFrameBase:(CGRect)frameBase;

@end
