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

@interface XYWKTool()<SKStoreProductViewControllerDelegate>

@end
@implementation XYWKTool
static XYWKTool *_tool;
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


/*
在中午做了一个很饿很饿的梦，把我都特么吓哭了
 
 1.我又回到到了大学时代，似乎这次我是一个混子
 2.大学是在天津某个村子，额那个诡异的村子似乎本身就在一股巨大的氤氲和魔咒李出不来
 3.平添了很多的仇家，似乎动不动就会招来杀身之祸
 4.这次的我好像更爱学习了，在学校教室的午休中居然梦到被第一节上课的老师吵醒。上一届的学生居然所有的用品都完整的摆在了书桌上，什么都不用准备居然就都全了，兴奋的我居然要做梦中发朋友圈了，因为我上过这么多年学，居然没有几个像样的笔都，想想都惭愧，但是也因为眼前准备好的一切而兴奋，在梦中都能感觉到那种：老子几年之后居然又回来上学了，开心。
 5.学校所在额地方不知道有什么魔咒一般，似乎自己出门分分钟都会迷路和失踪一般。颇像黄老邪的桃花岛,邪性十足，十分恐怖
 
*/


@end
