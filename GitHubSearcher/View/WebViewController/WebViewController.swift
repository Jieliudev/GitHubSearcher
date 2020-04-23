//
//  WebViewController.swift
//  GitHubSearcher
//
//  Created by Peter on 4/18/20.
//  Copyright © 2020 JieLiu. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    func setupWebView() {
        webView.navigationDelegate = self
        if let urlString = urlString,
            let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
}
