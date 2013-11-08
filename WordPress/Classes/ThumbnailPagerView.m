//
//  ThumbnailPagerView.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/07/30.
//

#import "ThumbnailPagerView.h"

CGFloat const hOffset = 9.0f; // 左右の余白
CGFloat const vOffset = 6.0f; // 上下の余白

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
    
    CGRect rectBase = CGRectMake(0,vOffset,_scrollObjectWidth - (hOffset*2), _scrollObjectHeight-(vOffset*2));
    NSArray *blogs = self.items;
    CGFloat curXloc = hOffset;
    // ブログごとにサムネイルのビューを作成し、サブビューとして追加
    for( Blog *blog in blogs ){
        // サムネイルのImageViewを調整。
        CGRect rect = CGRectOffset(rectBase, curXloc, 0);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBlogThumbnail)];
        [imageView addGestureRecognizer:recognizer];
        imageView.userInteractionEnabled = YES;
        imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        imageView.layer.shadowOffset = CGSizeMake(0,0);
        imageView.layer.shadowOpacity = 0.5f;
        [self addSubview:imageView];
        
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
    if(!self.currentPosition){
        self.currentPosition = num;
    }
    
    // postTypePagerViewのスクロール位置として、サイドバーの状態を適用
    NSInteger position = [self sidebarViewController].currentIndexPath.row;
    [self postTypePagerView].currentPosition = position;
    [[self postTypePagerView] update];
    
    // 前へ/次へボタン
    CGFloat x = _scrollObjectWidth - _nextButton.bounds.size.width - hOffset;
    CGFloat y = (_scrollObjectHeight/2) - (_nextButton.bounds.size.height/2) + vOffset;
    _prevButton.frame = CGRectMake(hOffset, y, _nextButton.bounds.size.width, _nextButton.bounds.size.height);
    _nextButton.frame = CGRectMake(x, y, _nextButton.bounds.size.width, _nextButton.bounds.size.height);
    [self.superview addSubview:_prevButton];
    [self.superview addSubview:_nextButton];
    
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
    //[indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat size = 21;
    CGFloat x = (_scrollObjectWidth/2) - (size/2) - hOffset;
    CGFloat y = (_scrollObjectHeight/2) - (size/2) - vOffset;
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
    
    UIImageView* imageView = [[self subviews] objectAtIndex:position];
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
    if([[self subviews] count] < index+1){
        [self reset];
        return;
    }
    UIImageView *imageView = [[self subviews] objectAtIndex:index];
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
    UIImageView *imageView = [[self subviews] objectAtIndex:index];
    
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
