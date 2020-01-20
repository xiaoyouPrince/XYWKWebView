//
//
//  ViewController.swift
//  WKWebViewDemo
//
//  Created by 渠晓友 on 2018/6/26.
//
//  Copyright © 2018年 xiaoyouPrince. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController , WKUIDelegate{

//    var webView: WKWebView!
//    lazy var link : CADisplayLink! = { [weak self] in
//        let link = CADisplayLink(target: self ?? UIView(), selector: #selector(loadProgerss))
//        return link
//    }()
//    lazy var progressView : UIProgressView! = { [weak self] in
//        let progressView = UIProgressView(progressViewStyle: .default)
//        progressView.frame = CGRect(x: 0, y: 100, width: (self?.view.frame.size.width)!, height: 5)
//        return progressView
//        }()
//
//
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//        view = webView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let myURL = URL(string:"https://www.apple.com")
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
//        link.add(to: RunLoop.current, forMode: .commonModes)
//
//        webView.allowsBackForwardNavigationGestures = true
//
//        // 监听
//        webView.addObserver(self, forKeyPath: "isLoading", options: .old, context: nil)
//    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 进入一个新的页面
        let webVC = WebViewController()
        let nav = UINavigationController(rootViewController: webVC)
        self .present(nav, animated: true, completion: nil)
        
//        let config = WKWebViewConfiguration()
//        let webView = WKWebView(frame: CGRect(x: 0, y: 84, width: UIScreen.main.bounds.size.width, height: 300), configuration:config)
//        self.view.addSubview(webView)
//
//        let path = Bundle.main.path(forResource: "main", ofType: "html")
//        let url = URL(string: path!)
//
//        do {
//            let str = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
//            print("content is: \(str)")
//            webView.loadHTMLString(str, baseURL: nil)
//        }
//        catch {
//            print("file read failed!")
//        }

        
        
        
        
        
        
    }
}

extension ViewController{
   
//    @objc func loadProgerss(){
//        print(webView.estimatedProgress)
//        self.view.addSubview(progressView)
//        self.progressView.progress = Float(webView.estimatedProgress)
//
//        if webView.estimatedProgress == 1.0 {
//            link.remove(from: RunLoop.current, forMode: .commonModes)
//            progressView.removeFromSuperview()
//        }
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        print("keypath = \(String(describing: keyPath))")
//        print("object = \(String(describing: object))")
//        print("change = \(String(describing: change))")
//        print("context = \(String(describing: context))")
//
//        print("webView.isLoading = \(webView.isLoading)")
//
//
//    }
}




