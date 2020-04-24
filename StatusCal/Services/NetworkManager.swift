//
//  NetworkManager.swift
//  StatusCal
//
//  Created by Alexey Boldakov on 23.04.2020.
//  Copyright © 2020 Alex Boldakov. All rights reserved.
//

import Foundation

class NetworkManager {

    static let shared = NetworkManager()
    
    private let url = URL(string: Constants.lastVersionURL)!
    private var session: URLSession = URLSession.shared
    
    init() {
        
    }
    
    func checkLastVersion(completion: @escaping (VersionResponse?, Error?) -> Void ) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                 completion(nil, error)
            } else {
                if let data = data, let version = try? JSONDecoder().decode(VersionResponse.self, from: data)  {
                    completion(version, nil)
                }
                completion(nil, nil)
            }
        }
        task.resume()
    }
}
