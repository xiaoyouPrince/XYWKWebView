//
//
//  XYWKWebViewController.m
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/28.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

#define XYWKScreenW [UIScreen mainScreen].bounds.size.width
#define XYWKScreenH [UIScreen mainScreen].bounds.size.height
#define XYWKiPhoneX (XYWKScreenH == 812) // iPhone X height
#define XYWKNavHeight (XYWKiPhoneX ? (88.f) : (64.f))  // statusBarH + TopBarH

#ifdef DEBUG
#define XYWKLog(...) NSLog( @"< %s:(第%d行) > %@",__func__ , __LINE__, [NSString stringWithFormat:__VA_ARGS__] )
#define XYWKFunc DLog(@"");
#else
#define XYWKLog( s, ... )
#define XYWKFunc;
#endif

#import "XYWKWebViewController.h"
#import "XYWKTool.h"

@interface XYWKWebViewController ()

@property(nonatomic , strong) UIView  *HUD;
@property(nonatomic , strong) UIProgressView  *progressView;

@end

@implementation XYWKWebViewController

#pragma mark - Life Circle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _showHudWhenLoading = YES;
        _shouldShowProgress = YES;
        _isUseWebPageTitle = YES;
        _alwaysAllowSideBackGesture = YES;
        _scrollEnabled = YES;
    }
    
    return self;
}

- (void)loadView
{
    // 直接自定义WebView为self.view
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    _webView = [[XYWKWebView alloc]initWithFrame:CGRectZero configuration:config];
    _webView.scrollView.scrollEnabled = _scrollEnabled;
    _webView.xy_messageHandlerDelegate = self;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    self.view = _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"加载中";
    
    if (self.shouldShowProgress) {
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    if (self.isUseWebPageTitle) {
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    if (self.url.length) {
        [self.webView loadRequestWithRelativeUrl:self.url];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideLoadingProgressView];
    [self hideHUD];
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    NSLog(@"dealloc --- %@",NSStringFromClass([self class]));
    if (self.shouldShowProgress) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
    if (self.isUseWebPageTitle) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        CGRect frame = CGRectMake(0, XYWKNavHeight, XYWKScreenW, 5);
        _progressView = [[UIProgressView alloc] initWithFrame:frame];
    }
    return _progressView;
}


- (void)hideLoadingProgressView{
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

- (void)showLoadingProgress:(CGFloat)progress andTintColor:(UIColor *)color{
    
    if (!self.progressView.superview) {
        [self.view addSubview:self.progressView];
    }
    self.progressView.progress = progress;
    self.progressView.tintColor = color;
    
    // 如果progress = 1.0 自动移除
    if(progress == 1.0f)
    {
        [self hideLoadingProgressView];
    }
}

- (UIView *)HUD{
    if (_HUD == nil) {
        _HUD = [UIView new];
        _HUD.frame = CGRectMake(50, 0, XYWKScreenW - 100, XYWKScreenH);
        _HUD.backgroundColor  = [UIColor clearColor];
        
        UILabel *tip = [UILabel new];
        tip.text = @"正在加载...";
        tip.textAlignment = NSTextAlignmentCenter;
        [_HUD addSubview:tip];
        tip.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        CGFloat X = _HUD.frame.size.width/4;
        CGFloat width = _HUD.frame.size.width/2;
        CGFloat height = 50;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            tip.frame = CGRectMake(X, XYWKScreenH/2 - 100, width, height);
        });
        tip.layer.cornerRadius = 5;
        tip.clipsToBounds = YES;
    }
    return _HUD;
}

- (void)showHUD{
    if (!self.HUD.superview) {
        [self.view addSubview:self.HUD];
    }
}

- (void)hideHUD{
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}


#pragma mark -- setters
// 设置内部的WebView是否可以允许系统左滑返回之前浏览页面的功能
- (void)setAlwaysAllowSideBackGesture:(BOOL)alwaysAllowSideBackGesture{
    self.webView.allowsBackForwardNavigationGestures = alwaysAllowSideBackGesture;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == self.webView) {
            if (self.showHudWhenLoading) {
                [self showLoadingProgress:self.webView.estimatedProgress andTintColor:[UIColor colorWithRed:24/255.0 green:124/255.0 blue:244/255.0f alpha:1.0]];
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            if ([self isUseWebPageTitle]) {
                self.title = self.webView.title;
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - SHWKWebViewMessageHandleDelegate

- (void)xy_webView:(XYWKWebView *)webView didReceiveScriptMessage:(XYScriptMessage *)message
{
    NSLog(@"webView method:%@",message.method);
    
    //返回上一页
    if ([message.method isEqualToString:@"tobackpage"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    //打开新页面
    else if ([message.method isEqualToString:@"openappurl"]) {
        
        NSString *url = [message.params objectForKey:@"url"];
        if (url.length) {
            XYWKWebViewController *webViewController = [[XYWKWebViewController alloc] init];
            webViewController.url = url;
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
}


#pragma mark - WKNavigationDelegate

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    if (_showHudWhenLoading) {
        [self showHUD];
    }
    
    NSLog(@"%s：%@", __FUNCTION__,webView.URL);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self hideHUD];
    
    // 实际上是首页加载完成之后就会走这个方法
    NSLog(@"%s 这个页面加载完成了",__func__);
    
}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%s%@", __FUNCTION__,error);
#warning TODO -- should hide loading Progress
#warning TODO -- should hide HUD
    [self hideLoadingProgressView];
    [self hideHUD];
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
    // 这里进行重定向了，例如 网页内下载APP 链接，起初是https://地址。重定向之后itms-appss:// 这里需要重新让WebView加载一下
    NSString *redirectionUrlScheme = webView.URL.scheme;
    if ([redirectionUrlScheme isEqualToString:@"itms-appss"]) {
        [XYWKTool jumpToAppStoreFromVc:self withUrl:webView.URL];
    }
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@"%s", __FUNCTION__);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"URL: %@", navigationAction.request.URL.absoluteString);
    
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"urlStr.lastPathComponent = %@",urlStr.lastPathComponent);
    
    if (!navigationAction.targetFrame.isMainFrame) {
        
        NSString *jsStr = @"var a = document.getElementsByTagName('a');"
                            "for(var i=0;i<a.length;i++)"
                            "{a[i].setAttribute('target','');"
                            "}";

        // 执行JS代码，移除内部 <a/> 中的_blank属性，所有内容都在本页面打开
        [webView evaluateJavaScript:jsStr completionHandler:nil];

        // 如果是这种情况下，直接加载一次最新的request即可
        [webView loadRequest:navigationAction.request];
    }
    
    // 这个回调必须调用<且只能调用一次>，无论位置是新页面的前或后
    decisionHandler(WKNavigationActionPolicyAllow);
}


/**
 当上面的内容为新打开一个UI页面就invoke这个方法
 
 @param webView <#webView description#>
 @param configuration <#configuration description#>
 @param navigationAction <#navigationAction description#>
 @param windowFeatures <#windowFeatures description#>
 @return <#return value description#>
 */
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    WKFrameInfo *frameInfo = navigationAction.targetFrame;
//    if (![frameInfo isMainFrame]) {
//        [webView loadRequest:navigationAction.request];
//    }
//    return nil;
//}


- (NSString *)valueForParam:(NSString *)param inUrl:(NSURL *)url {
    
    NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
    for (NSString *params in queryArray) {
        NSArray *temp = [params componentsSeparatedByString:@"="];
        if ([[temp firstObject] isEqualToString:param]) {
            return [temp lastObject];
        }
    }
    return @"";
}

- (NSMutableDictionary *)paramsOfUrl:(NSURL *)url {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
    for (NSString *params in queryArray) {
        NSArray *temp = [params componentsSeparatedByString:@"="];
        NSString *key = [temp firstObject];
        NSString *value = temp.count == 2 ? [temp lastObject]:@"";
        [paramDict setObject:value forKey:key];
    }
    return paramDict;
}

- (NSString *)stringByJoinUrlParams:(NSDictionary *)params {
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        [arr addObject:[NSString stringWithFormat:@"%@=%@",key,params[key]]];
    }
    return [arr componentsJoinedByString:@"&"];
}

- (NSString *)urlWithoutQuery:(NSURL *)url {
    NSRange range = [url.absoluteString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        return [url.absoluteString substringToIndex:range.location];
    }
    return url.absoluteString;
}

#pragma mark - WKUIDelegate

/**
 *  处理js里的alert
 *
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  处理js里的confirm
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  处理js里的 textInput 需要在根据情况做
 */
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{}




@end
