//
//
//  XYWKWebViewController.h
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/28.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYWKWebView.h"
#import "XYScriptMessage.h"

@interface XYWKWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate,XYWKWebViewMessageHandleDelegate>

@property (nonatomic, strong) XYWKWebView *webView;
@property (nonatomic, copy) NSString *url;
/**
 * JS & App 协议的交互名称
 * 用于子类化自由设置,默认 @“webViewApp”
 */
@property (nonatomic, copy) NSString * webViewAppName;

#pragma mark -- navigation

/**
 *  加载时是否显示HUD提示层(默认YES)
 */
@property (nonatomic, assign) BOOL showHudWhenLoading;

/**
 *  是否显示加载进度 (默认YES)
 */
@property (nonatomic, assign) BOOL shouldShowProgress;

/**
 *  是否使用WebPage的title作为导航栏title（默认YES）
 */
@property (nonatomic, assign) BOOL isUseWebPageTitle;

#pragma mark --

/**
 *  是否允许WebView内部的侧滑返回（默认YES）
 */
@property (nonatomic, assign) BOOL alwaysAllowSideBackGesture;

/**
 *  是否支持滚动（默认YES）
 */
@property (nonatomic, assign) BOOL scrollEnabled;

/**
 *  是否使用web页面导航栏(默认NO)
 */
@property (nonatomic, assign) BOOL useWebNavigationBar;

#pragma mark - 微信 & 支付宝 H5支付

/**
 * 微信H5支付的 Referer -- 即完成回跳 App 的 Scheme
 * @note 这个参数必须为申请微信支付的”授权安全域名“
 * @note 在 Info.plist 中 @b 必须 设置相同的 App 回调 URL Scheme
 */
@property (nonatomic, copy) NSString * wx_Referer;

/**
 * 支付宝H5支付的 AppUrlScheme -- 即完成回跳 App 的 Scheme
 * @note 在 Info.plist 中 @b 必须 设置相同的 App 回调URL Scheme
 */
@property (nonatomic, copy) NSString * zfb_AppUrlScheme;

@end
