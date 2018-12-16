//
//  Extensions.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

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
    
    func stringToDate() -> Date {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter1.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let date = dateFormatter1.date(from: self)
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter2.dateFormat = "E, d MMM yyyy HH:mm:ss z"
        let date2 = dateFormatter2.date(from: self)
        
        guard let dateUnwrapped = date else { return date2 ?? Date() }
        return dateUnwrapped
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

extension Date {
    
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, h:mm"
        let date = dateFormatter.string(from: self)
        return date
    }
    
}
