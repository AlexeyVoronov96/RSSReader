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

    @IBOutlet var slideInView: UIView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var blurViewConstraintRight: NSLayoutConstraint!
    @IBOutlet var blurViewConstraintLeft: NSLayoutConstraint!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    @IBOutlet var mainViewConstraintRight: NSLayoutConstraint!
    @IBOutlet var mainViewConstraintLeft: NSLayoutConstraint!
    var sideMenuOpen = false
    var tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
        let swipeLeft = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mainViewTapped(_:)))
        blurView.addGestureRecognizer(tapGesture)
        blurView.isUserInteractionEnabled = true
    }
    
    @objc func mainViewTapped(_ sender: UITapGestureRecognizer) {
        
        sideMenuOpen = true
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                        object: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            sideMenuOpen = false
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                            object: nil)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            sideMenuOpen = true
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                            object: nil)
        }
    }
    
    @objc func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuOpen = false
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 0
                self.sideMenuConstraint.constant = -240
                self.mainViewConstraintLeft.constant = 0
                self.mainViewConstraintRight.constant = 0
                self.blurViewConstraintLeft.constant = 0
                self.blurViewConstraintRight.constant = 0
            }
        } else {
            sideMenuOpen = true
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 1
                self.sideMenuConstraint.constant = 0
                self.mainViewConstraintRight.constant = 0
                self.mainViewConstraintLeft.constant -= 240
                self.blurViewConstraintLeft.constant -= 240
                self.blurViewConstraintRight.constant = 0
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
