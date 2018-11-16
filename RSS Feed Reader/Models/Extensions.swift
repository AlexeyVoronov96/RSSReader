//
//  Extensions.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UIView {
    func captureView() -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, scale)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image:UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
