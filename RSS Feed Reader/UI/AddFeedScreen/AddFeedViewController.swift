//
//  AddFeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 01.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {
    enum State {
        case create
        case update
        
        var title: String {
            switch self {
            case .create:
                return "Add feed".localize()
                
            case .update:
                return "Update feed".localize()
            }
        }
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var feedNameTextField: UITextField!
    @IBOutlet private var feedLinkTextField: UITextField!
    @IBOutlet private var acceptButton: UIButton!
    
    private let addFeedService = AddFeedService.shared
    
    var item: Feed?
    
    var state: State {
        return item == nil ? .create : .update
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        item = addFeedService.feed
        
        titleLabel.text = state.title
        acceptButton.setTitle(state.title, for: .normal)
        
        if state == .update {
            feedNameTextField.text = item?.name
            feedLinkTextField.text = item?.link
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        addFeedService.feed = nil
    }
    
    @IBAction private func acceptButtonAction(_ sender: UIButton) {
        guard let name = feedNameTextField.text,
            let link = feedLinkTextField.text,
            !name.isEmpty,
            !link.isEmpty else {
                showError(with: "All fields should be filled")
                return
        }
        
        guard link.isValidURL else {
            showError(with: "Invalid url")
            return
        }
        
        switch state {
        case .create:
            Feed.newFeed(name: name, link: link)
            
        case .update:
            item?.name = name
            item?.link = link
        }
        
        CoreDataManager.shared.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
