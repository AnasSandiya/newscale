//
//  ViewController.swift
//  AdvanceWebApp
//
//  Created by Shahid Ghafoor on 01/05/2019.
//  Copyright © 2019 Shahid Ghafoor. All rights reserved.
//

import UIKit
import WebKit
import Foundation
import SafariServices
import SystemConfiguration

class ViewController: UIViewController, WKUIDelegate ,WKNavigationDelegate {
    
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var noInternetView: UIView!
    @IBOutlet weak var webView: WKWebView!
    let targetUrl:String = "https://www.newscale.app/"
    
    var backPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isInternetAvailable() {
            self.vBack.isHidden = true
            // webview navigation
            noInternetView.isHidden = true
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.bounces = true
            let myURL = URL(string: targetUrl)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
            // swipe left or right for going back or forward
            webView.allowsBackForwardNavigationGestures = true
        //    webView.canGoBack = true
        } else {
            noInternetView.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !isInternetAvailable() {
            noInternetView.isHidden = false
        } else {
            noInternetView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish..loading")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if(backPressed){
            self.vBack.isHidden = true
            self.backPressed = false
        }else{
            let backURL = webView.backForwardList.backItem?.url.description
            if(backURL == "https://www.newscale.app/ranking"){
                self.vBack.isHidden = false
                
            }
            
        }
        
        
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
               let host = url.host, !host.hasPrefix("www.newscale.app"),
               UIApplication.shared.canOpenURL(url) {
                print( url)
                print(host)
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                decisionHandler(.cancel)
            } else {
                print(navigationAction.request.url!)
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func showAlert() {
        if !isInternetAvailable() {
            let alert = UIAlertController(title: "Warning", message: "The Internet is not available", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onOkClick(_ sender: Any) {
        if !isInternetAvailable() {
            noInternetView.isHidden = false
        } else {
            noInternetView.isHidden = true
        }
    }
    
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
       
        let str = "https://www.newscale.app/home"
        let myURL = URL(string: targetUrl)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        self.backPressed = true
       // self.vBack.isHidden = true
        
       
        
    }
    
}

