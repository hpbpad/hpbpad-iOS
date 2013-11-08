//
//  PostSEOViewController.m
//  hpbpad
//
//  Created by Ryo Yagyuda on 2013/08/30.
//

#import "PostSEOViewController.h"
#import "EditPostViewController_Internal.h"
#import "Post.h"
#import "NSString+Helpers.h"

@interface PostSEOViewController ()

@property (nonatomic, strong) AbstractPost *apost;
@property (nonatomic, strong) NSDictionary *SEOData;
@property (nonatomic, strong) NSString *prevTitle;
@property (nonatomic, strong) NSString *prevContent;
@property BOOL flg;

@end

@implementation PostSEOViewController {
}

- (id)initWithPost:(AbstractPost *)aPost {
    self = [super init];
    if (self) {
        self.apost = aPost;
        self.flg = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeIndicator];
    [self makeErrorMessage];
    [errorMessageView setHidden:YES];
    
    titleBalloonView = [[PostSEOBalloonView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    keywordsChartBalloonView = [[PostSEOBalloonView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    contentsBalloonView = [[PostSEOBalloonView alloc] initWithFrame:CGRectMake(0,0,0,0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshSEO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    scrollView = nil;
    titleContainer = nil;
    contentsContainer = nil;
    titleLabel = nil;
    contentsLabel = nil;
    keywordsChartContainer = nil;
    keywordsChartLabel = nil;
    keywordsChartView = nil;
    errorMessageView = nil;
    errorMessageLabel = nil;
    titleBalloonView = nil;
    contentsBalloonView = nil;
    titleLabelWrap = nil;
    //keywordsChartLabelWrap = nil;
    contentsLabelWrap = nil;
    keywordsChartBalloonView = nil;
    [super viewDidUnload];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self makeSEO];
    [self makeErrorMessage];
    [self makeIndicator];
}

- (void)notifyRotatedViewFrame:(CGRect)viewFrame {
    [self setIndicatorPositionWithViewFrame:viewFrame];
    [self setErrorMessagePositionWithViewFrame:viewFrame];
}

#pragma mark -
#pragma mark Instance Methods

- (Post *)post {
    if ([self.apost isKindOfClass:[Post class]]) {
        return (Post *)self.apost;
    } else {
        return nil;
    }
}

-(BOOL)hasChanges {
    BOOL hasChanges;
    if(self.prevTitle != [self post].postTitle || self.prevContent != [self post].content){
        hasChanges = YES;
    } else {
        hasChanges = NO;
    }
    return hasChanges;
}

-(void)save {
    self.prevTitle = [self post].postTitle;
    self.prevContent = [self post].content;
}

-(void)refreshSEO {
    // 変更があれば、更新を行う
	BOOL edited = [self hasChanges];
    // 初回なら、更新を行う
    if(self.flg){
        edited = YES;
        self.flg = NO;
    }
    // 前回のリクエストがエラーだったなら、更新を行う
    if(scrollView.hidden){
        edited = YES;
    }
	if (edited) {
        [self loadSEO];
	}
    [self save];
}

-(NSDictionary *)requestParams {
	NSString *title = self.apost.postTitle;
    if(title == nil){ title = @""; }
	NSString *contents = [self.apost.content stringByStrippingHTML];
    contents = [contents stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if(contents == nil){ contents = @""; }
    NSString *h1 = @"headline...";
    NSArray *keys = [NSArray arrayWithObjects:@"title",@"h1",@"contents", nil];
    NSArray *objects = [NSArray arrayWithObjects:title,h1,contents, nil];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

-(void)loadSEO {
    [self startLoading];
    
    NSURL *url = [NSURL URLWithString:@"https://api.masteraxis.com/app/util"];
    NSString *path = @"hpb_mobile_wp/";
    
    NSDictionary* params = [self requestParams];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:path parameters:params];
    //[request setTimeoutInterval:30];
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSDictionary *dict = JSON;
                [self showSEO:dict];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                //NSLog([NSString stringWithFormat:@"[statusCode] %d",[response statusCode]]); // エラーコード取得
                //NSLog([NSString stringWithFormat:@"%@", error]);
                [self showErrorMessage];
            }];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html",nil]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

-(void)showSEO:(NSDictionary*)dict {
    self.SEOData = dict;
    [self makeSEO];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [indicator stopAnimating];
    });
    [scrollView setHidden:NO];
}

-(void)showErrorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [indicator stopAnimating];
    });
    [errorMessageView setHidden:NO];
}

-(void)makeSEO {
    UIColor *bgColor = [UIColor UIColorFromHex:0xdcdcdc];   //Gainsboro
    self.view.backgroundColor = bgColor;
    scrollView.backgroundColor = bgColor;
    
    CGFloat const kMargin = 8;
    CGFloat const kMarginWide = kMargin * 2;
    CGFloat const kLabelMargin = 10;
    CGFloat const w = self.view.frame.size.width;
    CGFloat h = 0;
    CGFloat y = 0;

    CGRect const frameBase = CGRectMake(kMarginWide,
                                        kMarginWide,
                                        w-(kMarginWide*2),
                                        20+(kLabelMargin*2));
    CGRect const labelFrame = CGRectMake(kLabelMargin,
                                         kLabelMargin,
                                         frameBase.size.width-kLabelMargin,
                                         frameBase.size.height-(kLabelMargin*2));

    // タイトル
    UILabel *titleEntryLabel = [[UILabel alloc] init];
    titleEntryLabel.backgroundColor = [UIColor clearColor];
    titleEntryLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    titleEntryLabel.frame = CGRectMake(kMarginWide,
                                       kMarginWide,
                                       w-(kMarginWide*2),
                                       titleEntryLabel.font.lineHeight + kMargin);
    titleEntryLabel.text = @"タイトル"; //TODO:localize
    [scrollView addSubview:titleEntryLabel];
    y = titleEntryLabel.frame.size.height;
    
    titleLabelWrap.frame = frameBase;
    titleLabelWrap.layer.borderWidth = 0;
    titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    titleLabel.text = self.prevTitle;
    titleLabel.frame = labelFrame;
    titleBalloonView.frameBase = CGRectMake(frameBase.origin.x,
                                            titleLabelWrap.frame.origin.y + titleLabelWrap.frame.size.height + 8,
                                            frameBase.size.width,
                                            0);
    titleBalloonView.text = [self messageWithData:[self.SEOData valueForKey:@"title"]];
    [titleBalloonView makeBalloon];
    [titleContainer addSubview:titleBalloonView];
    h = titleLabelWrap.frame.size.height + 8 + titleBalloonView.frame.size.height + kMarginWide;
    titleContainer.frame = CGRectMake(0,y,w,h);
    y += h;
    
    // ページの構成ワード
    keywordsChartLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    keywordsChartLabel.frame = CGRectMake(kMarginWide,
                                          kMarginWide,
                                          w-(kMarginWide*2),
                                          keywordsChartLabel.font.lineHeight + kMargin);
    keywordsChartLabel.text = @"ページの構成ワード"; //TODO:localize
    [keywordsChartContainer addSubview:keywordsChartLabel];
    [self makeKeywordChartWithFrame:frameBase];
#if 0
    h = keywordsChartLabel.frame.size.height + kMargin + keywordsChartView.frame.size.height + kMarginWide;
#else
    keywordsChartBalloonView.frameBase = CGRectMake(frameBase.origin.x,
                                                    keywordsChartLabel.frame.origin.y + keywordsChartLabel.frame.size.height + keywordsChartView.frame.size.height + 8,
                                                    frameBase.size.width,
                                                    0);
    keywordsChartBalloonView.text = @"ユーザーが検索に使用すると思われるキーワードを効果的に織り交ぜてください。";   //TODO:localize
    [keywordsChartBalloonView makeBalloon];
    [keywordsChartContainer addSubview:keywordsChartBalloonView];
    h = keywordsChartLabel.frame.size.height + kMargin + keywordsChartView.frame.size.height + keywordsChartBalloonView.frame.size.height + kMarginWide;
#endif
    keywordsChartContainer.frame = CGRectMake(0,y,w,h);
    y += h;

    // 本文
    UILabel *contentsEntryLabel = [[UILabel alloc] init];
    contentsEntryLabel.backgroundColor = [UIColor clearColor];
    contentsEntryLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    contentsEntryLabel.frame = CGRectMake(kMarginWide,
                                          y + kMarginWide,
                                          w-(kMarginWide*2),
                                          contentsEntryLabel.font.lineHeight);
    contentsEntryLabel.text = @"本文"; //TODO:localize
    [scrollView addSubview:contentsEntryLabel];
    h = contentsEntryLabel.frame.size.height + kMargin;
    y += h;

    contentsLabelWrap.frame = frameBase;
    contentsLabelWrap.layer.borderWidth = 0;
    contentsLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    contentsLabel.lineBreakMode = UILineBreakModeTailTruncation;
    contentsLabel.text = self.prevContent;
    contentsLabel.frame = labelFrame;
    contentsBalloonView.frameBase = CGRectMake(frameBase.origin.x,
                                               contentsLabelWrap.frame.origin.y + contentsLabelWrap.frame.size.height + 8,
                                               frameBase.size.width,
                                               0);
    contentsBalloonView.text = [self messageWithData:[self.SEOData valueForKey:@"contents"]];
    [contentsBalloonView makeBalloon];
    [contentsContainer addSubview:contentsBalloonView];
    h = contentsLabelWrap.frame.size.height + 8 + contentsBalloonView.frame.size.height + kMarginWide;
    contentsContainer.frame = CGRectMake(0,y,w,h);
    y += h;
    
    [scrollView setContentSize:CGSizeMake(w,y+kMarginWide)];
}

-(NSString*)messageWithData:(NSDictionary*)data {
    NSString *message = [data valueForKey:@"message"];
    return [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

-(void)makeKeywordChartWithFrame:(CGRect)frame {
    for (UIView *subview in [keywordsChartView subviews]) {
        [subview removeFromSuperview];
    }
    
    NSArray *array = [self.SEOData valueForKey:@"keywordbalance"];
    CGFloat max = 0;
    if([array count] > 0 ){
        max = [[[array objectAtIndex:0] objectForKey:@"per"] floatValue];
    }
    
    CGFloat const offset = 10;
    CGFloat x, y = offset, h = 15, labelW = 110, numW = 25, perW = 45;
    if(frame.size.width>500){ labelW = 240; }
    CGFloat barW = frame.size.width - labelW - numW -5 - perW - (offset*2);
    
    UIColor *bgColor = [UIColor whiteColor];
    
    for (NSDictionary* item in array) {
        x = offset;
        
        UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelW, h)];
        keywordLabel.text = [NSString stringWithFormat:@"%d.%@",[array indexOfObject:item]+1,[item objectForKey:@"keyword"]];
        keywordLabel.font = [UIFont systemFontOfSize:12.0];
        keywordLabel.backgroundColor = bgColor;
        x = x + labelW;
        
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, numW, h)];
        numLabel.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"num"]];
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.font = [UIFont systemFontOfSize:13.0];
        numLabel.backgroundColor = bgColor;
        x = x + numW +5;
        
        NSString *per = [item objectForKey:@"per"];
        NSInteger perInt = [per floatValue] + 0.5f;
        
        CGFloat mw = barW * [per floatValue]/max;
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(x, y, mw, h)];
        bar.backgroundColor = [UIColor UIColorFromHex:0x29c1ff];
        x = x + barW;
        
        UILabel *perLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, perW, h)];
        //perLabel.text = [NSString stringWithFormat:@"%@%%",per];
        perLabel.text = [NSString stringWithFormat:@"%d%%",perInt];
        perLabel.textAlignment = NSTextAlignmentRight;
        perLabel.font = [UIFont systemFontOfSize:13.0];
        perLabel.backgroundColor = bgColor;
        
        [keywordsChartView addSubview:keywordLabel];
        [keywordsChartView addSubview:numLabel];
        [keywordsChartView addSubview:bar];
        [keywordsChartView addSubview:perLabel];
        y = y + h + offset;
    }
    keywordsChartView.backgroundColor = bgColor;
    keywordsChartView.frame = CGRectMake(frame.origin.x,
                                         frame.origin.y + keywordsChartLabel.frame.size.height,
                                         frame.size.width,
                                         y);
    CALayer *layer = keywordsChartView.layer;
    layer.frame = keywordsChartView.frame;
    layer.borderWidth = 0;
    //layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)setIndicatorPositionWithViewFrame:(CGRect)viewFrame {
    if (indicator) {
        CGFloat size = 21;
        CGFloat x = (viewFrame.size.width/2) - (size/2);
        CGFloat y = (viewFrame.size.height/2) - (size/2);
        if(IS_IPAD){
            x = size + IPAD_WIDE_PANEL_WIDTH/2;
        }
        indicator.frame = CGRectMake(x,y,size,size);
    }
}

- (void)makeIndicator {
    bool const fInit = !indicator ? true : false;
    if (fInit) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [self setIndicatorPositionWithViewFrame:self.view.frame];
    if (fInit) {
        [self.view addSubview:indicator];
    }
}

- (void)startLoading {
    [errorMessageView setHidden:YES];
    [scrollView setHidden:YES];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [indicator startAnimating];
    });
}

- (void)setErrorMessagePositionWithViewFrame:(CGRect)viewFrame {
    CGFloat x = (viewFrame.size.width/2) - (errorMessageView.frame.size.width/2);
    CGFloat y = (viewFrame.size.height/2) - (errorMessageView.frame.size.height/2);
    errorMessageView.frame = CGRectMake(x,y,errorMessageView.frame.size.width,errorMessageView.frame.size.height);

}

- (void)makeErrorMessage {
    errorMessageLabel.text = @"SEO情報を読み込めませんでした。"; //TODO: localize
    [self setErrorMessagePositionWithViewFrame:self.view.frame];
    [self.view addSubview:errorMessageView];
}

@end



