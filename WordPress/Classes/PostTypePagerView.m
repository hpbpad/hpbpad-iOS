//
//  PostTypePagerView.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/30.
//

#import "PostTypePagerView.h"

const CGFloat kPostTypeHeight = 35.0;
const CGFloat kPostTypeWidth = 130.0;

@implementation PostTypePagerView {
    CGFloat _scrollObjectHeight;
    CGFloat _scrollObjectWidth;
}

@synthesize items;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Viewが追加されたタイミング
- (void)didMoveToSuperview {
    self.delegate = (id)self;
    _scrollObjectHeight = kPostTypeHeight;
    _scrollObjectWidth = kPostTypeWidth;
}

// タッチ範囲として認識するルール
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // labelが無い部分も画面端までタッチを受け付ける(始端位置なので、片側分を加算)
    CGFloat x = 0 - _scrollObjectWidth;
    CGFloat y = self.bounds.origin.y;
    // labelが無い部分も画面端までタッチを受け付ける(幅なので、両端分を加算)
    CGFloat w = self.contentSize.width + ( _scrollObjectWidth *2);
    CGFloat h = self.bounds.size.height;
    // この範囲内なら、自身のイベントと判断する
    if (CGRectContainsPoint(CGRectMake(x,y,w,h), point)) {
        return self;
    }
    // そうでなければ、元々の対象へ
    UIView* hitView = [super hitTest:point withEvent:event];
    return hitView;
}

// スクロールし終えたタイミング
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    NSInteger page = offset.x / _scrollObjectWidth;
    if(page != self.currentPosition){
        self.currentPosition = page;
        [self update];
    }
}

// viewの準備
- (void)reset {
    // まず既に存在するサブビューをすべて削除する
    for (UIView* subView in [self subviews]){
        [subView removeFromSuperview];
    }
    CGFloat curXloc = 0;
    // 新しくサブビューを生成・追加していく
    NSArray* postTypes = self.items;
    for( PostType *postType in postTypes ){
        CGRect rect = CGRectMake(curXloc, -1, _scrollObjectWidth, _scrollObjectHeight);
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        [self makeLabel:label];
        label.text = postType.label;
        [self addSubview:label];
        curXloc += (_scrollObjectWidth);
    }
    // 区切り線の調整。(最後のlabelの区切り線を消す)
    if([[self subviews] count] > 0 ){
        UILabel *lastLabel = [[self subviews] objectAtIndex:[[self subviews] count] -1];
        lastLabel.layer.sublayers = nil;
    }
    // スクロール範囲を指定
    [self setContentSize:CGSizeMake(([postTypes count] * _scrollObjectWidth), _scrollObjectHeight)];
    // スクロール位置を0に戻す
    self.currentPosition = 0;
    [self update];
}

// viewの状態にcurrentPositionを適用する
- (void)update {
    self.contentOffset = CGPointMake(self.currentPosition * _scrollObjectWidth, 0);
    NSInteger i = 0;
    for (UILabel* label in [self subviews]) {
        if(i == self.currentPosition){
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        } else {
            label.textColor = [UIColor grayColor];
            label.font = [UIFont fontWithName:@"Helvetica" size:12];
        }
        i++;
    }
}

// Labelの調整。長いので分けた。
- (void) makeLabel:(UILabel *)label {
    label.textAlignment = UITextAlignmentCenter;
    //label.textColor = [UIColor grayColor];
    label.textColor = [UIColor colorWithRed:148.0f/255.0f green:147.0f/255.0f blue:147.0f/255.0f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    CALayer* layer = label.layer;
    CALayer* rightBorder = [CALayer layer];
    rightBorder.borderColor = [UIColor lightGrayColor].CGColor;
    rightBorder.borderWidth = 1;
    rightBorder.frame = CGRectMake(layer.frame.size.width-1, layer.frame.size.height/4, 1, layer.frame.size.height/2);
    [layer addSublayer:rightBorder];
}


@end
