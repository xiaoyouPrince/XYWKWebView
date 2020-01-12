//
//
//  XYWKWebView.m
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/28.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

#import "XYWKWebView.h"
#import "XYScriptMessage.h"

//这里可以统一设置WebView的访问域名，方便切换
#ifdef DEBUG
#   define BASE_URL_API    @"http://****/"   //测试环境
#else
#   define BASE_URL_API    @"http://****/"   //正式环境
#endif

@interface XYWKWebView ()

@property (nonatomic, strong) NSURL *baseUrl;

@end

@implementation XYWKWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        
        //默认允许系统自带的侧滑后退
        self.allowsBackForwardNavigationGestures = YES;
        self.baseUrl = [NSURL URLWithString:BASE_URL_API];
        
        //设置允许JS自动打开新window
        WKPreferences *preference = [WKPreferences new];
        preference.javaScriptCanOpenWindowsAutomatically = YES;
    }
    
    return self;
}

#pragma mark - Load Url

- (void)loadRequestWithRelativeUrl:(NSString *)relativeUrl; {
    
    
    // 这里目前只支持HTTP(s)协议，如果需要跳转到App Store就需要验证对应的Scheme : itms-appss
    [self loadRequestWithRelativeUrl:relativeUrl params:nil];
}

- (void)loadRequestWithRelativeUrl:(NSString *)relativeUrl params:(NSDictionary *)params {
    
    NSURL *url = [self generateURL:relativeUrl params:params];
    
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}

- (void)loadLocalHTML:(NSString *)htmlName withAddingStyleJS:(NSString *)styleJS funcJS:(NSString *)funcJS FooterJS:(NSString *)footerJS
{
    
    if (footerJS == nil) {
        return; // 如果html为空直接返回。
    }
    
    
    // 找到对应HTML内容
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSMutableString * htmlCont = [NSMutableString stringWithContentsOfFile:htmlPath
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:nil];
    
    // 插入Style代码
    NSRange rangeOfTitle = [htmlCont rangeOfString:@"</title>"];
    [htmlCont insertString:styleJS atIndex:rangeOfTitle.location + rangeOfTitle.length + 1];
    
    // 插入JS代码
    NSRange rangeOfScript = [htmlCont rangeOfString:@"<script type=\"text/javascript\">"];
    [htmlCont insertString:funcJS atIndex:rangeOfScript.location + rangeOfScript.length + 1];
    
    // 插入html代码
    NSRange rangeOfBody = [htmlCont rangeOfString:@"</body>"];
    [htmlCont insertString:footerJS atIndex:rangeOfBody.location];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}




- (NSURL *)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    
    self.webViewRequestUrl = baseURL;
    self.webViewRequestParams = params;
    
    return [NSURL URLWithString:baseURL];
    
    
    ///// 下面代码有待改进
//    http://39.107.94.38:8001/dist/index.html#/?usertype=1&usercode=wr&pwd=F_F%2B%2B--S4f39064d6853af39661ed33b55dee150    ok
//    http://39.107.94.38:8001/dist/index.html%23/?usertype=1&usercode=wr&pwd=F_F%252B%252B--S4f39064d6853af39661ed33b55dee150&
    
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSMutableArray* pairs = [NSMutableArray array];
    
    for (NSString* key in param.keyEnumerator) {
        NSString *value = [NSString stringWithFormat:@"%@",[param objectForKey:key]];
        
//        NSString* escaped_value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                                                                        (__bridge CFStringRef)value,
//                                                                                                        NULL,
//                                                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
//                                                                                                        kCFStringEncodingUTF8);
        
        NSCharacterSet *chars = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
        NSString* escaped_value = [value stringByAddingPercentEncodingWithAllowedCharacters:chars];
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
    }
    
    NSString *query = [pairs componentsJoinedByString:@"&"];
    baseURL = [baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* url = @"";
    if ([baseURL containsString:@"?"]) {
        url = [NSString stringWithFormat:@"%@&%@",baseURL, query];
    }
    else {
        url = [NSString stringWithFormat:@"%@?%@",baseURL, query];
    }
    //绝对地址
    if ([url.lowercaseString hasPrefix:@"http"]) {
        return [NSURL URLWithString:url];
    }
    else {
        return [NSURL URLWithString:url relativeToURL:self.baseUrl];
    }
}

/**
 *  重新加载webview
 */
- (void)reloadWebView {
    [self loadRequestWithRelativeUrl:self.webViewRequestUrl params:self.webViewRequestParams];
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    XYWKLog(@"message:%@",message.body);
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *body = (NSDictionary *)message.body;
        
        XYScriptMessage *msg = [XYScriptMessage new];
        [msg setValuesForKeysWithDictionary:body];
        
        if (self.xy_messageHandlerDelegate && [self.xy_messageHandlerDelegate respondsToSelector:@selector(xy_webView:didReceiveScriptMessage:)]) {
            [self.xy_messageHandlerDelegate xy_webView:self didReceiveScriptMessage:msg];
        }
    }
    
}

#pragma mark - JS

- (void)callJS:(NSString *)jsMethod {
    [self callJS:jsMethod handler:nil];
}

- (void)callJS:(NSString *)jsMethod handler:(void (^)(id _Nullable))handler {
    
    XYWKLog(@"call js:%@",jsMethod);
    [self evaluateJavaScript:jsMethod completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response);
        }
    }];
}


@end
