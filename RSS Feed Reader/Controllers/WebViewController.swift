//
//  WebViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var webView: UIWebView! 
    
    var url: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationItem.title = self.name
        DispatchQueue.main.async {
            self.webView.loadRequest(URLRequest(url: URL(string: self.url!)!))
        }
    }

}
