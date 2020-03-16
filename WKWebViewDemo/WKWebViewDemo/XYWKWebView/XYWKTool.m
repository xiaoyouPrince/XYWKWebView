//
//
//  XYWKTool.m
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/7/3.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//
//  抽取一个可扩展工具类

#import "XYWKTool.h"
#import <StoreKit/StoreKit.h>
#import "XYWKWebViewController.h"

@implementation NSDictionary (JSON)
- (NSString *)jsonString
{
    NSMutableString *strM = [[NSMutableString alloc] initWithString:@"{\n"];
    for (NSString *key in self.keyEnumerator) {
        [strM appendFormat:@"%@: \"%@\",\n",key,self[key]];
    }
    [strM appendString:@"}"];
    return strM;
}

@end

@interface XYWKTool()<SKStoreProductViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
/** 本地临时图片地址数组 */
@property (nonatomic, strong)       NSMutableArray * tempImagePathArray;

@end
@implementation XYWKTool
static __weak XYWKWebViewController * _webVC;
static NSString * _webViewCallBackMethod;
static XYWKTool *_tool;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tempImagePathArray = @[].mutableCopy;
    }
    return self;
}

+ (void)jumpToAppStoreFromVc:(UIViewController *)fromVc withUrl:(NSURL *)url
{
    // 通常App Store的scheme形式为 itms-appss://itunes.apple.com/cn/app/id382201985?mt=8
    // 取出appID
    NSString *urlLastPathComponent = url.lastPathComponent;
    NSString *idStr = [[urlLastPathComponent componentsSeparatedByString:@"?"] firstObject];
    NSString *appID = [idStr substringFromIndex:2];
    
    [self jumpToAppStoreFromVc:fromVc withAppID:appID];
}

/**
 应用内跳转到App Store页
 */
+ (void)jumpToAppStoreFromVc:(UIViewController *)fromVc withAppID:(NSString *)appID
{
    
    // 直接禁用之前页面,并不可重复点击
    if (!fromVc.view.isUserInteractionEnabled) return;
    [fromVc.view setUserInteractionEnabled:NO];
    
    
    // 创建对象
    SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc] init];
    // 设置代理
    _tool = _tool ?: [self new];
    storeVC.delegate = _tool;
    // 初始化参数
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appID forKey:SKStoreProductParameterITunesItemIdentifier];
    
    // 跳转App Store页
    [storeVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"错误信息：%@",error.userInfo);
        }
        else
        {
            // 弹出模态视图
            [fromVc presentViewController:storeVC animated:YES completion:^{
                [fromVc.view setUserInteractionEnabled:YES];
            }];
        }
    }];
}


#pragma mark -- SKStoreProductViewControllerDelegate
/**
 SKStoreProductViewControllerDelegate 方法，选择完成之后的处理
 @param viewController SKStoreProductViewController
 */
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    NSLog(@"将要退出 App Store 页面了");
    [viewController dismissViewControllerAnimated:YES completion:^{
        NSLog(@"已经退出 App Store 页面完成了");
    }];
}


+ (void)openURLFromVc:(UIViewController *)fromVc withUrl:(NSURL *)url
{
    // 处理是否是去AppStore
    // 这里进行重定向了，例如 网页内下载APP 链接，起初是https://地址。重定向之后itms-appss:// 这里需要重新让WebView加载一下
    NSString *redirectionUrlScheme = url.scheme;
    if ([redirectionUrlScheme isEqualToString:@"itms-appss"]) {
        [XYWKTool jumpToAppStoreFromVc:fromVc withUrl:url];
        return;
    }
    
    // 处理手机上内部App
    BOOL success = [[UIApplication sharedApplication] canOpenURL:url];
    if (success) {
        // 打开App
        if (__builtin_available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }else
    {
        // 设置弹窗
        NSString *string = [NSString stringWithFormat:@"无法打开%@，因为 iOS 无法识别以\"%@\"开头的互联网地址",url,url.scheme];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:string preferredStyle:UIAlertControllerStyleAlert];
        // 确定按键不带点击事件
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [fromVc presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 相册相关


+ (void)chooseImageFromVC:(UIViewController *)fromVc sourceType:(UIImagePickerControllerSourceType)type callBackMethod:(NSString *)callback
{
    if ([fromVc isKindOfClass:XYWKWebViewController.class]) {
        _webVC = (XYWKWebViewController *)fromVc;
        _webViewCallBackMethod = callback;
    }
    
    // 进行弹出相册
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    _tool = _tool ?: [self new];
    vc.delegate = _tool;
    vc.sourceType = type;
    
    [_webVC presentViewController:vc animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = [info  objectForKey:UIImagePickerControllerOriginalImage];
    
    NSInteger randNUM = arc4random()%100;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png",(randNUM)]];   // 保存
    [self.tempImagePathArray addObject:filePath];
    [UIImagePNGRepresentation(image) writeToFile: filePath atomically:YES];
        
    NSDictionary *dict = @{
        @"localOriginalUri": filePath,
        @"localCompressedUri": filePath,
    };
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [_webVC.webView callJS:[NSString stringWithFormat:@"%@(%@)", _webViewCallBackMethod,dict.jsonString]];
    }];
}



+ (void)removeTempImages
{
    if (_tool.tempImagePathArray.count) {
        for (NSString *path in _tool.tempImagePathArray) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
        }
        [_tool.tempImagePathArray removeAllObjects];
    }
}


#pragma mark - 地理位置相关

@end


