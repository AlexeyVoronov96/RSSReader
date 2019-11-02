//
//  Date+Extension.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 02.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Foundation

extension Date {
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, h:mm"
        let date = dateFormatter.string(from: self)
        return date
    }
}
