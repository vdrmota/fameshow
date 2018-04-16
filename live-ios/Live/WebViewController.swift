//
//  WebViewController.swift
//  Live
//
//  Created by Matt Schrage on 3/21/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import WebKit
import StoreKit

class WebViewController: UIViewController {
    @IBInspectable var urlPath: String = "http://fameshow.co/app/settings"
    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        webView.allowsLinkPreview = false
        view = webView
        
    }
    
    @IBAction func dismissNavigationController () {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
//        navigationController?.navigationBar.barStyle = .black;
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        let url = URL(string: self.urlPath)!
        webView.load(URLRequest(url: url))
        //webView.allowsBackForwardNavigationGestures = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor.colorWithRGB(red: 0, green: 0, blue: 0, alpha: 0.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor.colorWithRGB(red: 0, green: 0, blue: 0, alpha: 0.2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func requestRating (){
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = webView.title
        self.navigationItem.title = self.title
        
        let injectUsername = "var meta = document.createElement('meta'); var head = document.getElementsByTagName('head')[0]; meta.name = \"username\"; meta.content = \"\(User.currentUser.username ?? "")\"; head.appendChild(meta);"
        
        //inject the meta tag <meta name = "username" content = "mschrage">
        webView.evaluateJavaScript(injectUsername, completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelector(\"meta[scrollable]\").getAttribute(\"scrollable\")") { (result, error) -> Void in
                if error == nil {
                    print(result!)
                    
                    if let isScrollable = result as! String? {
                        webView.scrollView.isScrollEnabled = !(isScrollable == "false")
                    }
                }
            }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        switch navigationAction.navigationType {
        case .linkActivated:
            
            
            if let url = navigationAction.request.url {
                
                if let scheme = url.scheme {
                    if scheme == "open" {
                        UIApplication.shared.openURL(URL(string: url.absoluteString.replacingOccurrences(of: scheme + ":", with: ""))!)
                        print(url.absoluteString)
                        decisionHandler(.cancel)
                        return
                        
                    }
                    
                    if scheme == "rate" {
                        self.requestRating()
                        decisionHandler(.cancel)
                        return
                    }
                    
                    if scheme == "close" {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                        decisionHandler(.cancel)
                        return
                    }
                    
                    if scheme == "back" {
                        self.navigationController?.popViewController(animated: true)
                        decisionHandler(.cancel)
                        return
                    }
                }

                
                if let fragment = url.fragment {
                    if fragment == "open" {
                        // open outside of app
                        UIApplication.shared.openURL(URL(string: url.absoluteString.replacingOccurrences(of: fragment, with: ""))!)
                        print(url.absoluteString)
                        decisionHandler(.cancel)
                        return
                
                    }
                } else {
                    // open inapp
                    var next = WebViewController()
                    next.urlPath = url.absoluteString
                    self.navigationController?.pushViewController(next, animated: true)
                    decisionHandler(.cancel)
                    return
                }
            }
        default:
            break
        }
        
        if let url = navigationAction.request.url {
            print(url.absoluteString)
        }
        decisionHandler(.allow)
        
    }
}

