//
//  AddFeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 01.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {
    @IBOutlet private var feedNameTextField: UITextField!
    @IBOutlet private var feedLinkTextField: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction private func addFeedButtonAction(_ sender: UIButton) {
        guard let name = feedNameTextField.text,
            let link = feedLinkTextField.text else {
                showError(with: "All fields should be filled")
                return
        }
        
        guard link.isValidURL else {
            showError(with: "Invalid url")
            return
        }
        
        FeedsList.newFeed(name: name, link: link)
        CoreDataManager.shared.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
