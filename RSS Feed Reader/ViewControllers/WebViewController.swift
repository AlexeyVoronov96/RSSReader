//
//  WebViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var webView: UIWebView! 
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var url: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.topItem?.title = name
        webView.loadRequest(URLRequest(url: URL(string: url!)!))
    }

}
