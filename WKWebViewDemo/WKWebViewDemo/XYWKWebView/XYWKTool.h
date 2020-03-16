//
//
//  XYWKTool.h
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/7/3.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//
//  可扩展工具类

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)
- (NSString *)jsonString;
@end
@interface XYWKTool : NSObject

/// 调转到App Store
+ (void)jumpToAppStoreFromVc:(UIViewController *)fromVc withUrl:(NSURL *)url;
+ (void)jumpToAppStoreFromVc:(UIViewController *)fromVc withAppID:(NSString *)appID;

/// 打开对应App的URL
+ (void)openURLFromVc:(UIViewController *)fromVc withUrl:(NSURL *)url;

/// 选择图片相关
+ (void)chooseImageFromVC:(UIViewController *)fromVc sourceType:(UIImagePickerControllerSourceType)type callBackMethod:(NSString *)callback;
+ (void)removeTempImages;

@end
