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
}
