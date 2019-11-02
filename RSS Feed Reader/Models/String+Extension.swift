//
//  String+Extension.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 26/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation

extension String {
    var urlRegExp: String {
        return "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*)+)+(/)?(\\?.*)?"
    }

    var isValidURL: Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@",
                                    argumentArray:[urlRegExp])
        _ = NSPredicate.withSubstitutionVariables(predicate)
        return predicate.evaluate(with: self)
    }
    
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
