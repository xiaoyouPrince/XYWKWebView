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

@end
