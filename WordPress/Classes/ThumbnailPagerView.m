//
//  ThumbnailPagerView.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/30.
//

#import "ThumbnailPagerView.h"

CGFloat const outerOffset = 12.0f;
CGFloat const innerOffset = 6.0f;

@implementation ThumbnailPagerView {
    CGFloat _scrollObjectHeight;
    CGFloat _scrollObjectWidth;
    UIButton* _nextButton;
    UIButton* _prevButton;
}

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
    
    [self initSideButtons];
    //[self initPageControl];
    
    // thumbnail更新通知の監視
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateThumbnail:)
                                                 name:BlogThumbnailUpdatedNotification
                                               object:nil];
    // thumbnail更新エラー通知の監視
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateErrorThumbnail:)
                                                 name:BlogThumbnailUpdateErrorNotification
                                               object:nil];
}

// スクロールし終えたタイミング
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 現在のページ数を計算し、currentPositionと比較する
    CGPoint offset = scrollView.contentOffset;
    NSInteger page = offset.x / _scrollObjectWidth;
    if(page != self.currentPosition){
        
        // viewの状態を更新する
        self.currentPosition = page;
        [self update];
    }
}

// サムネイルをタップ
- (void)onTapBlogThumbnail{
    [self.topMenuViewController showPreview];
}

// Viewの準備を行う
- (void)reset {
    // まず既に存在するサブビューをすべて削除する
    for (UIView* subView in [self subviews]){
        [subView removeFromSuperview];
    }
    
    _scrollObjectHeight = self.bounds.size.height;
    _scrollObjectWidth = self.bounds.size.width;
    
    CGRect outerRect = CGRectMake(0,0,_scrollObjectWidth - (outerOffset*2), _scrollObjectHeight);
    CGRect innerRect = CGRectMake(innerOffset, innerOffset, outerRect.size.width - innerOffset*2, outerRect.size.height - innerOffset*2);
    
    NSArray *blogs = self.items;
    CGFloat curXloc = outerOffset;
    // ブログごとにサムネイルのビューを作成し、サブビューとして追加
    for( Blog *blog in blogs ){
        // サムネイルのImageViewを調整。
        //CGRect rect = CGRectMake(curXloc, 0, _scrollObjectWidth - outerOffset*2, _scrollObjectHeight);
        CGRect rect = CGRectOffset(outerRect, curXloc, 0);
        UIImageView *outer = [[UIImageView alloc] initWithFrame:rect];
        outer.image = [UIImage imageNamed:@"dropshadow"];
        outer.backgroundColor = [UIColor clearColor];
        outer.userInteractionEnabled = YES;
        
        //UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:innerRect];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        //[imageView setBackgroundColor:[UIColor whiteColor]];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBlogThumbnail)];
        [imageView addGestureRecognizer:recognizer];
        imageView.userInteractionEnabled = YES;
        
        [outer addSubview:imageView];
        [self addSubview:outer];
        // サムネイル読み込み＋表示
        UIImage *thumbnail = [blog getThumbnail];
        if(thumbnail){
            imageView.image = thumbnail;
        }else{
            UIActivityIndicatorView *indicator = [self indicator];
            [imageView addSubview:indicator];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [indicator startAnimating];
            });
        }
        curXloc += (_scrollObjectWidth);
    }
    // スクロール範囲を指定
    [self setContentSize:CGSizeMake(([blogs count] * _scrollObjectWidth), _scrollObjectHeight)];
    
    // スクロールの現在位置として、サイドバーの状態を適用
    NSInteger num = [self sidebarViewController].currentIndexPath.section;
    if(num > 0 ){ num--; }
    self.currentPosition = num;
    
    // postTypePagerViewのスクロール位置として、サイドバーの状態を適用
    NSInteger position = [self sidebarViewController].currentIndexPath.row;
    [self postTypePagerView].currentPosition = position;
    [[self postTypePagerView] update];
    
    // 前へ/次へボタン
    CGFloat x = _scrollObjectWidth - _nextButton.bounds.size.width - (outerOffset + innerOffset);
    CGFloat y = (_scrollObjectHeight/2) - (_nextButton.bounds.size.height/2) + outerOffset;
    _nextButton.frame = CGRectMake(x, y, _nextButton.bounds.size.width, _nextButton.bounds.size.height);
    _prevButton.frame = CGRectMake(outerOffset+innerOffset, y, _nextButton.bounds.size.width, _nextButton.bounds.size.height);
    [self.superview addSubview:_nextButton];
    [self.superview addSubview:_prevButton];
    
    // スクロール状態の更新
    [self update];
    
    // pageControl
    //[self resetPageControl];
}

// 横のボタン
- (void)initSideButtons {
    CGRect frame = CGRectMake(0,0,24,45);
    _nextButton = [[UIButton alloc] initWithFrame:frame];
    _nextButton.userInteractionEnabled = YES;
    [_nextButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(moveToNext)]];
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"arrow_r"] forState:UIControlStateNormal];
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"arrow_r_on"] forState:UIControlStateHighlighted];
    _prevButton = [[UIButton alloc] initWithFrame:frame];
    _prevButton.userInteractionEnabled = YES;
    [_prevButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(moveToPrev)]];
    [_prevButton setBackgroundImage:[UIImage imageNamed:@"arrow_l"] forState:UIControlStateNormal];
    [_prevButton setBackgroundImage:[UIImage imageNamed:@"arrow_l_on"] forState:UIControlStateHighlighted];
}
// 次へ
- (void)moveToNext {
    self.currentPosition++;
    [self update];
}
// 前へ
- (void)moveToPrev {
    self.currentPosition--;
    [self update];
}

// 読み込み中表示
- (UIActivityIndicatorView *)indicator {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    CGFloat size = 21;
    CGFloat offset = outerOffset + innerOffset;
    CGFloat x = ((_scrollObjectWidth - (offset * 2)) /2) - (size/2);
    CGFloat y = ((_scrollObjectHeight - (innerOffset*2))/2) - (size/2);
    indicator.frame = CGRectMake(x,y,size,size);
    return indicator;
}

// pageControl関連
- (void)initPageControl {
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.userInteractionEnabled = NO;
}
- (void)resetPageControl {
    CGRect rect = CGRectMake(0, self.bounds.size.height+20, self.bounds.size.width, 20);
    [self.pageControl removeFromSuperview];
    self.pageControl.frame = rect;
    self.pageControl.currentPage = self.currentPosition;
    self.pageControl.numberOfPages = [self.items count];
    [self.superview addSubview:self.pageControl];
}
- (void)updatePageControl {
    self.pageControl.currentPage = self.currentPosition;
}
    
// スクロール状態の更新
- (void)update {
    // currentPositionがブログ数をオーバーしてる場合などは戻してやる
    // また、端のサムネイルが表示されている場合はそれより先に行くボタンは非表示に。
    NSInteger min = 0;
    NSInteger max = [self.items count]-1;
    if(self.currentPosition <= min){
        self.currentPosition = min;
        [_prevButton setHidden:YES];
    }else{
        [_prevButton setHidden:NO];
    }
    
    if(self.currentPosition >= max){
        self.currentPosition = max;
        [_nextButton setHidden:YES];
    }else{
        [_nextButton setHidden:NO];
    }
    
    // スクロール位置をcurrentPositionの値に合わせる
    CGPoint point = CGPointMake(self.currentPosition * _scrollObjectWidth, 0);
    [self setContentOffset:point animated:YES];
    
    // サムネイル更新を行う(現在のスクロール位置を渡す)
    NSInteger position = self.currentPosition;
    [self performSelector:@selector(updateThumbnailPosition:) withObject:[NSNumber numberWithInt:position] afterDelay:1.0];
    
    // 状態の変化を反映して、postTypePagerViewを作り直す。
    [self postTypePagerView].items = [self postTypes];
    [[self postTypePagerView] reset];
    
    // サイドバーの状態を更新する
    SectionInfo *sectionInfo = [[self sidebarViewController].sectionInfoArray objectAtIndex:self.currentPosition];
    if (!sectionInfo.open) {
        [sectionInfo.headerView toggleOpenWithUserAction:NO];
    }
    
    // pageControlの状態を更新
    //[self updatePageControl];
}

// サムネイルを更新する
- (void)updateThumbnailPosition:(NSNumber *)number {
    NSInteger position = [number intValue];
    // 渡されてきたスクロール位置が現在の位置と違ったら、何もせず終了。
    if(position != self.currentPosition){ return; }
    // ブログが一つもなければ、何もせず終了。
    if([self.items count] < 1){ return; }
    // サムネイルを取得しなおす。
    Blog* blog = [self.items objectAtIndex:position];
    
    // getThumbnailで、すでにサムネイルが存在していればUIImageがかえってくる。この場合はupdateThumbnailを行う。
    // サムネイルが存在しない場合はnil返ってくる。このときは、getThumbnailの中でサムネイル取得を行う。
    BOOL getting=YES;
    if([blog getThumbnail]){
        [blog updateThumbnail];
        getting = NO;
    } else {
        getting = YES;
    }
    
    //UIImageView* imageView = [[self subviews] objectAtIndex:position];
    UIImageView* outer = [[self subviews] objectAtIndex:position];
    UIImageView* imageView = [[outer subviews] objectAtIndex:0]; // 子がimageViewしかいない前提
    for (id subview in imageView.subviews) {
        // グルグル開始
        if(getting && [subview isKindOfClass:[UIActivityIndicatorView class]]){
            [subview startAnimating];//TODO: スレッド
        }
        // ラベルを削除
        if([subview isKindOfClass:[UILabel class]]){
            [subview removeFromSuperview];
        }
    }
}

// サムネイル更新通知を受け取る
- (void)updateThumbnail:(NSNotification*)notification {
    Blog *blog = [[notification userInfo] objectForKey:@"blog"];
    NSUInteger index = [self.items indexOfObject:blog];
    if(index == NSNotFound){
        self.items = [[self sidebarViewController] blogs];
        [self reset];
        return;
    }
    //UIImageView *imageView = [[self subviews] objectAtIndex:index];
    UIImageView *outer = [[self subviews] objectAtIndex:index];
    UIImageView *imageView = [[outer subviews] objectAtIndex:0];
    imageView.image = blog.thumbnail;
    // 読み込み中表示があれば、止める。
    for (id subview in imageView.subviews) {
        if([subview isKindOfClass:[UIActivityIndicatorView class]]){
            [subview stopAnimating];//TODO: スレッド
        }
    }
}

// サムネイル更新失敗通知を受け取る
- (void)updateErrorThumbnail:(NSNotification*)notification {
    Blog *blog = [[notification userInfo] objectForKey:@"blog"];
    NSUInteger index = [self.items indexOfObject:blog];
    if(index == NSNotFound){
        index = 0;
    }
    //UIImageView *imageView = [[self subviews] objectAtIndex:index];
    UIImageView *outer = [[self subviews] objectAtIndex:index];
    UIImageView *imageView = [[outer subviews] objectAtIndex:0];
    
    //imageView.image = blog.thumbnail;
    // 読み込み中表示があれば、止める。
    for (UIView* subview in imageView.subviews) {
        if([subview isKindOfClass:[UIActivityIndicatorView class]]){
            [subview performSelector:@selector(stopAnimating)];//TODO: スレッド
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,subview.frame.origin.y -25,imageView.frame.size.width,50)];
            label.textAlignment = UITextAlignmentCenter;
            label.numberOfLines = 2;
            label.text = [NSString stringWithFormat:@"%@\nサムネイルを読み込めませんでした。",blog.blogName];
            label.font = [UIFont systemFontOfSize:15];
            [imageView addSubview:label];
        }
    }
}

/* 必要なものを取得する */
-(SidebarViewController *)sidebarViewController {
    return (SidebarViewController *)self.topMenuViewController.panelNavigationController.masterViewController;
}
-(PostTypePagerView *)postTypePagerView {
    return self.topMenuViewController.postTypePagerView;
}
-(NSArray *)postTypes {
    NSArray* postTypes = [NSArray array];
    if([self.items count] <= self.currentPosition){
        return postTypes;
    }
    Blog* blog = [self.items objectAtIndex:self.currentPosition];
    postTypes = [ blog.postLists valueForKeyPath:@"postType"];
    return postTypes;
}

@end
