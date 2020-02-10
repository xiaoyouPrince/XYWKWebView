# iOS App 接入 H5 支付

**「H5 支付」**是在手机浏览器中购买商品，发起支付的一种应用场景。

微信官方不建议在 App 内接入 H5 支付，但实际 App 开发中会有接入 Web 商城的实际需求。

本文档即是对 iOS App 中的 H5 支付的统一封装，整体基于 WKWebView，关于WKWebView的封装和使用可以看这篇文章[WKWebView 的封装和使用](README.md)

下面先说使用方法，然后再说实现思路

### 使用方法

**1.设置微信/支付宝支付完成回调 App 的 URL Scheme**

- 支付宝客户端H5支付回跳 App 的 Scheme 可以自定义，
- 微信客户端H5支付回跳 App 的 Scheme **必须为微信商户注册的微信支付安全域名**，此处问产品经理

**2.生成实例对象，设置对应的 wx_Referer 和 zfb_AppUrlScheme**

- wx_Referer 即微信支付的回调 Scheme
- zfb_AppUrlScheme 即支付宝支付回调的 Scheme

工具基类名：XYWKWebViewController ，建议使用子类继承，这样不同的业务模块可以互不影响，代码示例如下

```
// 直接赋值对应的回调Scheme即可。
XYWKWebViewController * vc = [XYWKWebViewController new];
vc.wx_Referer = @"wxser.fesco.com.cn";
vc.zfb_AppUrlScheme = @"testmobilepay";
[self.navigationController pushViewController:vc];
```


**H5 支付核心思路**

1. 网页内 H5 调起三方支付，发起统一下单接口。【此步骤为H5开发】
2. 统一支付返回值中会返回调起支付的中间页面，商户后台会发到支付平台。【此中间页面地址需要我们客户端自己处理，这样才可以在支付完成/取消之后回调到App页面】
3. 中间页面进行 H5 校验，成功后发起支付链接。【此处监听到支付链接需要我们客户端调起对应的支付App】

**注意：H5 页面调起三方支付，必须设置回到 App 的 URL scheme，否则回不到自己App**

下面是调试时候我这边检测到的支付调用

```
输入密码后确定支付: 其中每个地址都经过了urlencode处理

// 1.统一下单接口调用,其中域名为商户申请微信支付的安全域名。
http://wxser.xxxxx.com.cn/pay/index?app=3&sign=BD226DB5ADDC7DE913FAEB83D7A45271&orderno=TF202001170000798372&money=16900&description=%E5%BE%AE%E5%95%86%E5%9F%8E&tencentPayType=3&backurl=https%3A%2F%2Fwmall.fesco.com.cn%2Fpageview%2Fhtml%2FPersonal%2F%E6%94%AF%E4%BB%98%E6%88%90%E5%8A%9F.html

// 2.统一下单接口返回的微信支付中间页地址，由商户后台调用，发起微信支付
https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb?prepay_id=wx17101746455190817ba211ed1068551700&package=2480363457&redirect_url=https%3a%2f%2fwxser.fesco.com.cn%2fpay%2fH5PayBack

// 3.中间页通过验证，调起微信支付
weixin://wap/pay?prepayid%3Dwx17101746455190817ba211ed1068551700&package=2480363457&noncestr=1579227520&sign=31577677cb607b31def4781fa2d8be0d

// 支付宝处理
// 1. 统一支付接口链接
https://www.alipay.com/cooperate/gateway.do?service=alipay.wap.create.direct.pay.by.user&partner=2088011635010164&_input_charset=UTF-8&seller_email=DZSW%40fesco.com.cn&out_trade_no=TF202001190000380271&subject=%e7%a6%8f%e5%88%a9%e5%95%86%e5%93%81%e5%85%91%e6%8d%a2&body=%e7%a6%8f%e5%88%a9%e5%95%86%e5%93%81%e5%85%91%e6%8d%a2&total_fee=0.01&payment_type=1&app_pay=Y&return_url=http%3a%2f%2ffesco3.datayan.cn%2fOrder%2fwxAlipayHsh_New_Return&notify_url=http%3a%2f%2ffesco3.datayan.cn%2fOrder%2fAlipayHsh_New_Notify&sign=4b55fa10da04831fca8936b272645b57&sign_type=MD5

// 2. 支付宝反馈的支付中间页面
https://mclient.alipay.com/home/exterfaceAssign.htm?seller_email=DZSW%40fesco.com.cn&_input_charset=UTF-8&subject=%E7%A6%8F%E5%88%A9%E5%95%86%E5%93%81%E5%85%91%E6%8D%A2&sign=4b55fa10da04831fca8936b272645b57&body=%E7%A6%8F%E5%88%A9%E5%95%86%E5%93%81%E5%85%91%E6%8D%A2&notify_url=http%3A%2F%2Ffesco3.datayan.cn%2FOrder%2FAlipayHsh_New_Notify&alipay_exterface_invoke_assign_model=cashier&alipay_exterface_invoke_assign_target=mapi_direct_trade.htm&payment_type=1&out_trade_no=TF202001190000380271&partner=2088011635010164&alipay_exterface_invoke_assign_sign=_oe_srjnatso%2B_y8%2B_i6_sum_me_b_e_o_c_jgej_kd_w_gn_ivd_qds%2Bya36_p_g_z4_z_c_s_qg%3D%3D&service=alipay.wap.create.direct.pay.by.user&total_fee=0.01&app_pay=Y&return_url=http%3A%2F%2Ffesco3.datayan.cn%2FOrder%2FwxAlipayHsh_New_Return&sign_type=MD5&alipay_exterface_invoke_assign_client_ip=219.239.42.66

// 3. 调起支付宝支付的最终接口
alipay://alipayclient/?%7B%22requestType%22%3A%22SafePay%22%2C%22fromAppUrlScheme%22%3A%22alipays%22%2C%22dataString%22%3A%22h5_route_token%3D%5C%22RZ110bgnfPGrMUV7a2yVXp8lR31YgImobilecashierRZ11%5C%22%26is_h5_route%3D%5C%22true%5C%22%22%7D
```


### 微信H5支付流程和注意点

流程直接看文档[官方文档](https://pay.weixin.qq.com/wiki/doc/api/H5.php?chapter=15_1)

iOS 端注意点主要：

#### 1. Referer 和 redirect_url 说明

`HTTP Referer` 是 header 的一部分，当浏览器向web服务器发起请求的时，一般会带上 Referer，告诉服务器我是从哪个页面链接过来。微信中间页会对 Referer 进行校验，非安全域名将不能正常加载。

`redirect_url` 是微信中间页唤起微信支付之后，页面重定向的地址。中间页唤起微信支付后会跳转到指定的 redirect_url。并且微信APP在支付完成时，也是通过 redirect_url 回调结果，redirect_url一般是一个页面地址，所以微信支付完成会打开 Safari 浏览器。本文通过修改 redirect_url，实现微信支付完毕跳回当前APP。

> **注意：
> 微信会校验 Referer(来源) 和 redirect_url(目标) 是否是安全域名。如果不传redirect_url，微信会将 Referer 当成 redirect_url，唤起支付之后会重定向到 Referer 对应的页面，建议带上 redirect_url<br>
1.需对redirect_url进行urlencode处理
2.由于设置redirect_url后,回跳指定页面的操作可能发生在：1,微信支付中间页调起微信收银台后超过5秒 2,用户点击“取消支付“或支付完成后点“完成”按钮。因此无法保证页面回跳时，支付流程已结束，所以商户设置的redirect_url地址不能自动执行查单操作，应让用户去点击按钮触发查单操作**

  

#### 2. 必须设置微信支付完成回跳 App 的 URL Scheme

![微信回调Scheme](image/微信回调Scheme.png)

### 微信H5支付流程封装

弄清楚了微信支付流程，那封装思路就清晰了，这里只讲思路和接口，具体实现请参考[项目地址](https://www.github.com/xiaoyouPrince/WKWebViewDemo)

#### 1. wx_Referer 入参设置

```
/**
 * 微信H5支付的 Referer -- 即完成回跳 App 的 Scheme
 * @note 这个参数必须为申请微信支付的”授权安全域名“
 * @note 在 Info.plist 中 @b 必须 设置相同的 App 回调 URL Scheme
 */
@property (nonatomic, copy) NSString * wx_Referer;
```
#### 2. wx_redirect_url 源文件内部变量，存放拉起微信H5支付的回调地址

```
/**
 * 微信H5支付的重定向地址
 */
@property (nonatomic, copy) NSString * wx_redirect_url;
```

#### 3. 源文件实现逻辑(详见项目源码)

```
1. 重写 - webView: decidePolicyForNavigationAction: decisionHandler: 方法，处理每次请求
2. 处理中间页面地址【Scheme+域名为”https://wx.tenpay.com“】,查看是否包含重定向地址 `redirect_url`参数,
    3. 如果后台没有配置，则手动配置为 self.wx_Referer 如 abc.com:// 停止当前请求并发起新地址的请求
    4. 如果已经配置且不等于 self.wx_Referer 则设置为 self.wx_Referer 如 abc.com:// 并用`wx_redirect_url` 保存原来的重定向地址，停止当前请求并发起新地址的请求
    5. 如果已经配置且重定向地址为 self.wx_Referer 则直接通过本次请求不做处理
```

详细代码请看项目源码，里面混合了支付宝与微信的H5支付逻辑，有兴趣可以自行查阅。

### 支付宝H5支付流程和注意点

支付宝的支付逻辑就相对简单了，支付宝调起中间页校验成功之后会拉起支付宝，在拉起支付宝客户端我们对该地址进行处理，将我们的 App Scheme 替换给该地址内部的 `fromAppUrlScheme` 参数即可，支付宝客户端即可在支付完成/取消之后回调到我们的 App

#### 1. zfb_AppUrlScheme 入参设置

```
/**
 * 支付宝H5支付的 AppUrlScheme -- 即完成回跳 App 的 Scheme
 * @note 在 Info.plist 中 @b 必须 设置相同的 App 回调URL Scheme
 */
@property (nonatomic, copy) NSString * zfb_AppUrlScheme;
```

#### 2. 实现文件处理调起支付宝客户端

```
1. 重写 - webView: decidePolicyForNavigationAction: decisionHandler: 方法，处理每次请求
2. 处理拉起支付宝客户端的地址，标志为 URL Scheme 为 alipay
3. 将请求URL内的 fromAppUrlScheme 参数替换为我们自己 App Scheme。取消当前请求并发起新地址的请求
```

## 最后

我封装的好的项目地址，可以直接使用[项目地址](https://github.com/xiaoyouPrince/WKWebViewDemo)

如果此项目帮助到了你，欢迎点赞！

最后祝大家玩的愉快~

参考文章：
[微信H5支付](https://www.jianshu.com/p/65979e8bf251)
[支付宝H5支付](https://www.jianshu.com/p/72e867a7e40e)






