//
//  PostSEOBalloonView.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/09/11.
//

#import "PostSEOBalloonView.h"

CGFloat const offset = 10.0f;

@interface PostSEOBalloonView ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *ballonTopView;

@end


@implementation PostSEOBalloonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] init];
        self.ballonTopView = [[UIView alloc] init];
        [self addSubview:self.textView];
        [self addSubview:self.ballonTopView];
        self.textView.editable = NO;
        self.textView.contentInset = UIEdgeInsetsMake(offset,0,0,0);
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect {
}
*/

- (NSString *)text {
    return self.textView.text;
}
- (void)setText:(NSString *)text {
    self.textView.text = text;
}

- (void)setFrameBase:(CGRect)frameBase {
    self.frame = frameBase;
    self.textView.frame = frameBase;
}

- (void)makeBalloon {
    UIColor *bgColor = [UIColor UIColorFromHex:0xfde5d9];
    UIColor *borderColor = [UIColor UIColorFromHex:0xe2947c];
    CGFloat const angle = 45.0 * M_PI / 180.0;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.textView.contentSize.height+offset);
    self.textView.frame = CGRectMake(0, 0, self.frame.size.width, self.textView.contentSize.height+offset);
    
    self.textView.layer.borderWidth = 1;
    self.textView.layer.cornerRadius = 4;
    self.textView.backgroundColor = bgColor;

    [self.textView.layer setBorderColor:borderColor.CGColor];
    
    CALayer *balloonTop = [CALayer layer];
    balloonTop.frame = CGRectMake(20,-6,12,12);
    balloonTop.backgroundColor = bgColor.CGColor;
    balloonTop.affineTransform = CGAffineTransformMakeRotation(angle);
    [self.layer addSublayer:balloonTop];
    
    CALayer* rightBorder = [CALayer layer];
    rightBorder.backgroundColor = borderColor.CGColor;
    rightBorder.frame = CGRectMake(0,0,balloonTop.bounds.size.width,1);
    [balloonTop addSublayer:rightBorder];
    CALayer* leftBorder = [CALayer layer];
    leftBorder.backgroundColor = borderColor.CGColor;
    leftBorder.frame = CGRectMake(0,0,1,balloonTop.bounds.size.height);
    [balloonTop addSublayer:leftBorder];
}


@end
