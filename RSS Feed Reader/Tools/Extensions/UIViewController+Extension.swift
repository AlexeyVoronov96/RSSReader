//
//  UIViewController+Extension.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 02.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(with text: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: completion))
        present(alertController, animated: true, completion: nil)
    }
}
