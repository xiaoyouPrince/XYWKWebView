//
//
//  XYWKWebView.h
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/28.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

#define XYWKScreenW [UIScreen mainScreen].bounds.size.width
#define XYWKScreenH [UIScreen mainScreen].bounds.size.height
#define XYWKiPhoneX (XYWKScreenH >= 812) // iPhone X height
#define XYWKNavHeight (XYWKiPhoneX ? (88.f) : (64.f))  // statusBarH + TopBarH

#ifdef DEBUG
#define XYWKLog(...) NSLog( @"< %s:(第%d行) > %@",__func__ , __LINE__, [NSString stringWithFormat:__VA_ARGS__] )
#define XYWKFunc DLog(@"");
#else
#define XYWKLog( s, ... )
#define XYWKFunc;
#endif

#import <WebKit/WebKit.h>

@class XYWKWebView;
@class XYScriptMessage;

@protocol XYWKWebViewMessageHandleDelegate <NSObject>

@optional
- (void)xy_webView:(nonnull XYWKWebView *)webView didReceiveScriptMessage:(nonnull XYScriptMessage *)message;

@end

@interface XYWKWebView : WKWebView <WKScriptMessageHandler,XYWKWebViewMessageHandleDelegate>

//webview加载的url地址
@property (nullable, nonatomic, copy) NSString *webViewRequestUrl;
//webview加载的参数
@property (nullable, nonatomic, copy) NSDictionary *webViewRequestParams;

@property (nullable, nonatomic, weak) id<XYWKWebViewMessageHandleDelegate> xy_messageHandlerDelegate;

#pragma mark - Load Url

- (void)loadRequestWithRelativeUrl:(nonnull NSString *)relativeUrl;

- (void)loadRequestWithRelativeUrl:(nonnull NSString *)relativeUrl params:(nullable NSDictionary *)params;

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName;


/**
 定制化内容，底部添加分享和赞的功能

 @param footerJS 底部的功能部分JS代码
 */
- (void)loadLocalHTML:(nonnull NSString *)htmlName withAddingStyleJS:(nullable NSString *)styleJS funcJS:(nullable NSString *)funcJS FooterJS:(nullable NSString *)footerJS;

#pragma mark - View Method

/**
 *  重新加载webview
 */
- (void)reloadWebView;

#pragma mark - JS Method Invoke

/**
 *  调用JS方法（无返回值）
 *
 *  @param jsMethod JS方法名称
 */
- (void)callJS:(nonnull NSString *)jsMethod;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsMethod JS方法名称
 *  @param handler  回调block
 */
- (void)callJS:(nonnull NSString *)jsMethod handler:(nullable void(^)(__nullable id response))handler;

@end
