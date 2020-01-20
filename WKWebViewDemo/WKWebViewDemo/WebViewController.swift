//
//
//  WebViewController.swift
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/28.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

import UIKit

class WebViewController: XYWKWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// #用法0： 直接加载对应的地址 <没有参数>
//        self.webView.loadRequest(withRelativeUrl: "https://www.httpbin.org/")
        
        /// #用法1： 直接加载对应的地址 <有参数>
//        let params = ["name":"xiaoyou",
//                      "password" : "123456#/HTTP_Methods/get_get"]
//        self.webView.loadRequest(withRelativeUrl: "https://www.httpbin.org/", params: params)
        
        /// #用法2： 直接加载本地HTML文件 <没有参数>
        self.webView.loadLocalHTML(withFileName: "main")
        
        /// #用法3： JS 注入，添加一些方法 <这里的原生坐标和JS之间无法直接相对应>
        let margin : CGFloat = 6.0
        let padding : CGFloat = 10.0
        let width = UIScreen.main.bounds.size.width - (margin * 2.0) - (margin * 7.0 + padding)
        let btnWidth = (width - padding - 5) / 2.0
        
        let styleJS = """
                    <style type="text/css">
                    #foot {
                        border:solid 10px #600;
                        padding:\(padding)px;
                        margin:\(margin)px;
                        clear:both;
                        width:\(width)px
                    }
                    #share {
                        border:solid 1px #600;
                        padding:2px;
                        margin:2px;
                        clear:both;
                        width:\(btnWidth)px;
                        heiht:150px
                    }
                    #like {
                        border:solid 1px #600;
                        padding:2px;
                        margin:2px;
                        clear:both;
                        width:\(btnWidth)px;
                        heiht:50px
                    }
                    </style>
                    """
        
        let funcJS = """
                    \t\t\tfunction testFunc(text){\n
                    \t\t\t\tvar message = \"点我干什么\";\n
                    \t\t\t\twindow.webkit.messageHandlers.webViewApp.postMessage(message);\n
                    \t\t\t\talert(text);\n
                    \t\t\t}\n
                    """
        
        let footerJS = """
                    \t<button onclick=\"testFunc('http://www.baidu.com/')\">自己添加的Footer的Button一个</button><br /><br /><br />\n
                    \t <div id=\"foot\">底部说明 <br />
                    <button id=\"share\" onclick=\"testFunc('分享')\">分享</button>
                    <button id=\"like\" onclick=\"testFunc('点赞')\">点赞</button><br />
                    </div>
                    """
        self.webView.loadLocalHTML("main", withAddingStyleJS: styleJS, funcJS: funcJS, footerJS: footerJS)
//        self.webView.backgroundColor = UIColor.red
        
        /// 设置导航
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(backAction));
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "调用JS", style: .plain, target: self, action: #selector(callJS));
    }
    
    
    
    
    
}


/// #用法4： OC 调用JS方法。这里可以调用JS，把H5需要的参数传给他们
///  这里是JS 回调方法
extension WebViewController{
    
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func callJS() {
        self.webView.callJS("call('Hello World!')") { (response) in
            print("\(String(describing: response))")
        }
    }
    
    /// 这里是重写了WebView接受到JS消息的回调，需要调用super方法才能执行内部方法，否则这里只是打印
    override func xy_webView(_ webView: XYWKWebView, didReceive message: XYScriptMessage) {
        
        // 如果完全自定义的js方法处理，无需重写父类，自行实现即可
        super.xy_webView(webView, didReceive: message)
        print(message)
    }
    
}
