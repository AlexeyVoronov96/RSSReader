//
//  Checker.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 26/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import SystemConfiguration
import UIKit

func isInternetAvailable() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self,
                             capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}

func validateUrl (stringURL : NSString) -> Bool {
    let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*)+)+(/)?(\\?.*)?"
    let predicate = NSPredicate(format:"SELF MATCHES %@",
                                argumentArray:[urlRegEx])
    _ = NSPredicate.withSubstitutionVariables(predicate)
    return predicate.evaluate(with: stringURL)
}
