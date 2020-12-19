//
//  GithubUsersClient.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation

final class GithubUsersClient {
    private lazy var usersURL: URL = {
        return URL(string: "http://api.github.com/users")!
    }()

    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchUsers(since: Int, completion: @escaping (Result<[User], DataResponseError>) -> Void) {
        let urlRequest = URLRequest(url: usersURL)
        let parameters: [String : String] = ["per_page":"10", "since": "\(since)"]
        let encodedURLRequest = urlRequest.encode(with: parameters)
        
        session.dataTask(with: encodedURLRequest, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    return
            }
            
            // Check decoding error & callback with failure
            guard let decodedResponse = try? JSONDecoder().decode([User].self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }
            
            // Callback with Success
            completion(Result.success(decodedResponse))
        }).resume()
    }
}
