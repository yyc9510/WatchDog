//
//  AboutViewController.swift
//  WatchDog
//
//  Created by 姚逸晨 on 2/11/18.
//  Copyright © 2018 YICHEN YAO. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // webview load url page from azure
    override func viewWillAppear(_ animated: Bool) {
        let url = URL(string: "http://aboutuspage.azurewebsites.net/")!
        webView.load(URLRequest(url: url))
        
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = "About"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
