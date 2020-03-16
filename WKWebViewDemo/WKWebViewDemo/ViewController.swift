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
    @IBAction func localHTMLtest(_ sender: Any) {
        let webVC = WebViewController()
        navigationController?.pushViewController(webVC, animated: true)
    }
    @IBAction func unifiyTest(_ sender: Any) {
        let webVC = UnifiedAccessViewController()
        webVC.url = "http://39.107.94.38:8005/h5/#/?code=9940A63EC6DC1F9685FD54955DF51C0DA39F7C0FFCD21C0C47046FCF92ADBEAF193A7B7E12EF6FE0FB8214BAE565D90B67623E9FD8C68FE73E8FE0BB1CEF02F765710F5911633F10CAC5BB3929B5598974C66C54ADE386A30957E6515E1582A6";
        navigationController?.pushViewController(webVC, animated: true)
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




