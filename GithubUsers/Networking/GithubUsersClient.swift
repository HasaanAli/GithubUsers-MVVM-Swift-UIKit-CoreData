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
        NSLog("fetchUsers since: %d", since)
        let urlRequest = URLRequest(url: usersURL)
        let parameters: [String : String] = ["per_page":"50", "since": "\(since)"]
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
            guard let users = try? JSONDecoder().decode([User].self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }

            // Callback with Success
            completion(Result.success(users))
        }).resume()
    }

    func fetchImage(urlString: String, completion: @escaping (Data) -> Void) {
        let url: URL = URL(string: urlString)!
        let task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
            if let imageData = try? Data(contentsOf: url) {
                completion(imageData)
            } else {
                print("fetchImage download task: No data for image")
            }
        })
        task.resume()
    }
}
