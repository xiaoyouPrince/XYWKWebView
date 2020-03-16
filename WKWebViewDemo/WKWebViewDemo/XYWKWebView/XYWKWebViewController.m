//
//
//  XYWKWebViewController.m
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/28.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

#import "XYWKWebViewController.h"
#import "XYWKTool.h"
// 定位相关
#import <CoreLocation/CoreLocation.h>

@interface XYWKWebViewController ()<CLLocationManagerDelegate>

/** locationMgr */
@property (nonatomic, strong)       CLLocationManager * locationMgr;

@property(nonatomic , strong) UIView  *HUD;
@property(nonatomic , strong) UIProgressView  *progressView;

/**
 * 微信H5支付的重定向地址
 */
@property (nonatomic, copy) NSString * wx_redirect_url;

@end

@implementation XYWKWebViewController

#pragma mark - Life Circle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _webViewAppName = @"webViewApp";
        _showHudWhenLoading = YES;
        _shouldShowProgress = YES;
        _isUseWebPageTitle = YES;
        _alwaysAllowSideBackGesture = YES;
        _scrollEnabled = YES;
        _useWebNavigationBar = NO;
    }
    
    return self;
}

- (void)loadView
{
    // 直接自定义WebView为self.view
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    _webView = [[XYWKWebView alloc] initWithFrame:CGRectZero configuration:config];
    [config.userContentController addScriptMessageHandler:_webView name:_webViewAppName];
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
    
    if (self.useWebNavigationBar) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wk_backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
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
    XYWKLog(@"dealloc --- %@",NSStringFromClass([self class]));
    if (self.shouldShowProgress) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
    if (self.isUseWebPageTitle) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
    
    // 移除选择过的本地图片
    [XYWKTool removeTempImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        
        CGFloat progressViewY = XYWKNavHeight;
        if (self.useWebNavigationBar) {
            progressViewY = [UIApplication sharedApplication].statusBarFrame.size.height;
        }
        
        CGRect frame = CGRectMake(0, progressViewY, XYWKScreenW, 5);
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

#pragma mark - backActions
- (void)backAction
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - XYWKWebViewMessageHandleDelegate

- (void)xy_webView:(XYWKWebView *)webView didReceiveScriptMessage:(XYScriptMessage *)message
{
    XYWKLog(@"webView method:%@",message.method);
    
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
    //打开相册[目前只支持选择一张]
    else if ([message.method isEqualToString:@"chooseImage"]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"选择获取图片途径" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 默认相机，相册两个途径获取图片
        NSArray <NSString *>*src = message.params[@"sourceType"];
        if (!src) {
            src = @[@"album",@"camera"];
        }
        if ([src containsObject:@"album"]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [XYWKTool chooseImageFromVC:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary callBackMethod:message.callback];
            }]];
        }
        if ([src containsObject:@"camera"]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"从相机选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if ([self isSimuLator]) {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"当前设备不支持相机设备" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }else
                {
                    [XYWKTool chooseImageFromVC:self sourceType:UIImagePickerControllerSourceTypeCamera callBackMethod:message.callback];
                }
                
            }]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
    //获取用户地址
    else if ([message.method isEqualToString:@"getLocation"]) {
        
        if (!self.locationMgr) {
            self.locationMgr = [CLLocationManager new];
            self.locationMgr.delegate = self;
        }
        
        // 查看获取类型参数// 默认wgs84。 也可以传gcj02获取火星坐标
        NSString *type = message.params[@"type"];
        // 发起一次定位
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            [self.locationMgr startUpdatingLocation];
        }else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        {
            // 直接返回用失败
            NSDictionary *dict = @{
                @"failReason": @"用户拒绝使用位置权限"
            };
            [self.webView callJS:[NSString stringWithFormat:@"%@(%@)",message.callback,dict.jsonString]];
        }else //if (status == kCLAuthorizationStatusNotDetermined)
        {
            // 请求用户授权
            [self.locationMgr requestWhenInUseAuthorization];
        }
    }
    // 统一分享
    else if ([message.method isEqualToString:@"updateAppMessageShareData"]) {
        
        // 弹框
        //title: '', // 分享标题
        //desc: '', // 分享描述
        //link: '', // 分享链接，该链接域名或路径
        //imgUrl: '', // 分享图标
        //shareType
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"选择获取图片途径" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 默认相机，相册两个途径获取图片
        NSArray <NSString *>*src = message.params[@"shareType"];
        if (!src || !src.count) {
            src = @[@"1",@"2",@"3"];
        }
        if ([src containsObject:@"1"]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *dict = @{
                    @"title": [message.params valueForKey:@"title"],
                    @"desc": [message.params valueForKey:@"desc"],
                    @"link": [message.params valueForKey:@"link"],
                    @"imgUrl": [message.params valueForKey:@"imgUrl"]
                };
                [self.webView callJS:[NSString stringWithFormat:@"%@(%@)",message.callback,dict.jsonString]];
                
            }]];
        }
        if ([src containsObject:@"2"]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"朋友圈" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
               NSDictionary *dict = @{
                   @"title": [message.params valueForKey:@"title"],
                   @"desc": [message.params valueForKey:@"desc"],
                   @"link": [message.params valueForKey:@"link"],
                   @"imgUrl": [message.params valueForKey:@"imgUrl"]
               };
               [self.webView callJS:[NSString stringWithFormat:@"%@(%@)",message.callback,dict.jsonString]];
                
            }]];
        }
        if ([src containsObject:@"3"]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"分享链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                
               NSDictionary *dict = @{
                   @"title": [message.params valueForKey:@"title"],
                   @"desc": [message.params valueForKey:@"desc"],
                   @"link": [message.params valueForKey:@"link"],
                   @"imgUrl": [message.params valueForKey:@"imgUrl"]
               };
               [self.webView callJS:[NSString stringWithFormat:@"%@(%@)",message.callback,dict.jsonString]];
                
            }]];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -  请求地址位置和地理反编码
// 一开始就请求地理位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // 拿到最近的location,去解析地理位置，并请求对应的天气
    NSLog(@"请求到的地址为: - locations = %@",locations);
    
    // 解析第一个地址,用来请求位置
    CLLocation *location = locations.firstObject;
    // 返回用户的地理位置
    NSDictionary *dict = @{
        @"latitude": @(location.coordinate.latitude),
        @"longitude": @(location.coordinate.longitude),
        @"speed": @(location.speed),
        @"accuracy": @(10)
    };
    [self.webView callJS:[NSString stringWithFormat:@"%@(%@)",@"onGetLocation",dict.jsonString]];
    
    [self.locationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // 请求地理位置失败，自动重新开始？直接返回信息等用户手动调用
    NSDictionary *dict = @{
        @"failReason": @"定位失败"
    };
    [self.webView callJS:[NSString stringWithFormat:@"%@(%@)",@"onGetLocation",dict.jsonString]];
    
    [self.locationMgr stopUpdatingLocation];
}


/// 监听用户已经在设置中修改
/// @param manager manager description
/// @param status status description
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationMgr startUpdatingLocation];
    }
}

-(BOOL)isSimuLator
{
    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        //模拟器
        return YES;
    }else{
        //真机
        return NO;
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
    
    XYWKLog(@"%s：%@", __FUNCTION__,webView.URL);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    XYWKLog(@"%s", __FUNCTION__);
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
    XYWKLog(@"%s 这个页面加载完成了",__func__);
    
}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    XYWKLog(@"%s%@", __FUNCTION__,error);
    [self hideLoadingProgressView];
    [self hideHUD];
    
    // 当scheme为非 http(s)会引发错误
    // Error Domain= Code=0 "Redirection to URL with a scheme that is not HTTP(S)" UserInfo={_WKRecoveryAttempterErrorKey=<WKReloadFrameErrorRecoveryAttempter: 0x2835822a0>, NSErrorFailingURLStringKey=itms-appss://apps.apple.com/cn/app/id1092031003, NSErrorFailingURLKey=itms-appss://apps.apple.com/cn/app/id1092031003, NSLocalizedDescription=Redirection to URL with a scheme that is not HTTP(S)}
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    XYWKLog(@"%s", __FUNCTION__);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    XYWKLog(@"%s", __FUNCTION__);
    
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
    
    // 0. about:blank 处理
    if ([navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        // 停止当前请求
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([navigationAction.request.URL.scheme isEqualToString:@"file"]) {
        // 停止当前请求
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    // 1.处理JS需要在新Tab页面加载页面
    if (!navigationAction.targetFrame.isMainFrame) {

        NSString *jsStr = @"var a = document.getElementsByTagName('a');"
                            "for(var i=0;i<a.length;i++)"
                            "{a[i].setAttribute('target','');"
                            "}";

        // 执行JS代码，移除内部 <a/> 中的_blank属性，所有内容都在本页面打开
        [webView evaluateJavaScript:jsStr completionHandler:nil];
        // 如果是这种情况下，直接加载一次最新的request即可
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // 2. 处理基础Scheme加载过程，非HTTP(s)请求
    NSString *scheme = navigationAction.request.URL.scheme;
    BOOL HTTPScheme = [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"http"];
    if (!HTTPScheme) {
        
        // 非Http(s)Scheme,处理定向Scheme-即各类客户端
        // 2.1 确定Scheme是否可以识别
        BOOL bSucc = [[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL];
        if (!bSucc) {
            // 不可识别的，提示未安装客户端
            [XYWKTool openURLFromVc:self withUrl:navigationAction.request.URL];
            // 禁止通过,当前请求
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        else
        {
            // 可识别的单独处理一下微信支付宝
            // 2.2 可以识别的Scheme 定向处理微信/支付宝/公有Scheme如tel: mail: sms:
            // 2.2.1 定向处理微信 -> H5微信支付，单独处理
            NSString *newUrl = navigationAction.request.URL.absoluteString;
            if (self.wx_Referer) { // 只有在赋值之后默认检查微信H5支付
                NSString *referer = [NSString stringWithFormat:@"%@://",self.wx_Referer];
                if([newUrl isEqualToString:referer]){
                    
                    // 加载微信的重定向地址
                    if (self.wx_redirect_url) {
                        
                        self.wx_redirect_url = [self.wx_redirect_url stringByRemovingPercentEncoding];
                        
                        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self.wx_redirect_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                        [self.webView loadRequest:request];
                        self.wx_redirect_url = nil;
                    }
                }
            }
            
            // 2.2.2 针对支付宝处理
            if (self.zfb_AppUrlScheme) {// 只有赋值后检查支付宝H5支付
                if ([navigationAction.request.URL.scheme isEqualToString:@"alipay"]) {
                    
                    // 处理支付宝回调[url stringByReplacingOccurrencesOfString:@"%22alipays%22" withString:@"%22testmobilepay%22"]
                    NSString *alipayUrl = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
                    NSString *zfbScheme = [NSString stringWithFormat:@"\"%@\"",self.zfb_AppUrlScheme];
                    if (![alipayUrl containsString:zfbScheme]) {
                        // 没有替换，手动替换
                        alipayUrl = [alipayUrl stringByReplacingOccurrencesOfString:@"alipays" withString:self.zfb_AppUrlScheme];
                        dispatch_async(dispatch_get_main_queue(), ^{
                                
                            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[alipayUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                            [self.webView loadRequest:request];
                        });
                        
                        // 禁止通过此次请求
                        decisionHandler(WKNavigationActionPolicyCancel);
                        return;
                    }
                }
            }
            
            
            // 打开URL
            [XYWKTool openURLFromVc:self withUrl:navigationAction.request.URL];
            // 允许通过,当前请求
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        
        
//        return;
    }
    else // if (self.wx_Referer)
     // 3.处理HTTP(s)请求,主要处理微信H5支付中间页面
    {// 即用户设置了微信支付
        NSString *newUrl = navigationAction.request.URL.absoluteString;
        NSString *referer = [NSString stringWithFormat:@"%@://",self.wx_Referer];
        if ([newUrl rangeOfString:@"https://wx.tenpay.com"].location != NSNotFound) {
            
            // 拿到最后一个参数，即&redirect_url=xxx
            NSArray <NSString *>*paramsArray = [newUrl componentsSeparatedByString:@"="];
            NSString *backUrl = [paramsArray.lastObject stringByRemovingPercentEncoding];
            if ([backUrl isEqualToString:referer]) {
                
                // 通过，不做处理
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
            }else{
                
                self.wx_redirect_url = backUrl;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSRange range = [newUrl rangeOfString:@"redirect_url="];
                    NSString *reqUrl;
                    if (range.length>0) {
                        reqUrl = [newUrl substringToIndex:range.location+range.length];
                        reqUrl = [reqUrl stringByAppendingString:referer];
                    }else{
                        reqUrl = [newUrl stringByAppendingString:[NSString stringWithFormat:@"&redirect_url=%@",referer]];
                    }
                    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    //设置授权域名
                    [request setValue:referer forHTTPHeaderField:@"Referer"];
                    [self.webView loadRequest:request];
                });
                
                // 取消本次请求
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
        
        // 默认允许所有请求
        decisionHandler(WKNavigationActionPolicyAllow);
    }
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
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alert.textFields.firstObject.text);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}




@end
