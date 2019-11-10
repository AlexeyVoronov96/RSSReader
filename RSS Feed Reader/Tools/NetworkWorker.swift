//
//  NetworkWorker.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 10.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Foundation

class NetworkWorker {
    enum Errors: LocalizedError {
        case urlNil
        case dataNil
        
        var errorDescription: String? {
            return "Something goes wrong...".localize()
        }
    }
    
    func getData(with url: URL?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(Errors.urlNil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(Errors.dataNil))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
}
