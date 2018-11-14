//
//  ContainerViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 08/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import Toast_Swift

class ContainerViewController: UIViewController {
    
    static let containerController = ContainerViewController()
    
    var sideMenuOpen = false
    var tapGesture = UITapGestureRecognizer()
    var toast: String = ""
    
    @IBOutlet var slideInView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet var mainViewConstraintRight: NSLayoutConstraint!
    @IBOutlet var mainViewConstraintLeft: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name("ToggleSideMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toastText(_:)), name: NSNotification.Name(rawValue: "toast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showToast), name: NSNotification.Name("showToast"), object: nil)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func mainViewTapped(_ sender: UITapGestureRecognizer) {
        sideMenuOpen = true
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            sideMenuOpen = false
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            sideMenuOpen = true
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        }
    }
    
    @objc func showToast() {
        var style = ToastStyle()
        style.messageColor = Colors.sharedInstance.blue
        style.backgroundColor = Colors.sharedInstance.white
        ToastManager.shared.isTapToDismissEnabled = true
        self.view.makeToast(self.toast.localize(), duration: 3.0, position: .bottom, style: style)
    }
    
    @objc func toastText(_ notification: NSNotification) {
        if let toast = notification.object {
            self.toast = toast as! String
        }
    }
    
    @objc func toggleSideMenu() {
        
        switch sideMenuOpen {
        case true:
            do {
                self.sideMenuOpen = false
                UIView.animate(withDuration: 0.3) {
                    self.mainView.alpha = 1
                    self.sideMenuConstraint.constant = -240
                    self.mainViewConstraintLeft.constant = 0
                    self.mainViewConstraintRight.constant = 0
                    self.mainView.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    self.mainView.layer.cornerRadius = 0
                    self.mainView.layer.masksToBounds = true
                    self.mainView.isUserInteractionEnabled = true
                }
            }
        case false:
            do {
                self.sideMenuOpen = true
                UIView.animate(withDuration: 0.3) {
                    self.mainView.alpha = 0.7
                    self.sideMenuConstraint.constant = 0
                    self.mainViewConstraintRight.constant = 0
                    self.mainViewConstraintLeft.constant -= 240
                    self.mainView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9)
                    self.mainView.layer.cornerRadius = 15
                    self.mainView.layer.masksToBounds = true
                    self.mainView.isUserInteractionEnabled = false
                }
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
