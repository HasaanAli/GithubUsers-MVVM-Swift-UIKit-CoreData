//
//  GithubUsersClient.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation

final class GithubUsersClient {
    static let sharedInstance = GithubUsersClient()

    private lazy var usersURL: URL = {
        return URL(string: "http://api.github.com/users")!
    }()

    let session: URLSession
    
    private init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchUsers(since: Int, perPage: Int, completion: @escaping (Result<[User], DataResponseError>) -> Void) {
        NSLog("fetchUsers since: %d, perPage: %d", since, perPage)
        let urlRequest = URLRequest(url: usersURL)
        let parameters: [String : String] = ["per_page": "\(perPage)", "since": "\(since)"]
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
        session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
            if let imageData = try? Data(contentsOf: url) {
                completion(imageData)
            } else {
                print("fetchImage download task: No data for image")
            }
        }).resume()
    }

    func fetchUserDetails(login: String, completion: @escaping (Result<UserDetails, DataResponseError>) -> Void) {
        NSLog("fetchUserDetails login: %@", login)
        let userDetailsURL = URL(string: "http://api.github.com/users/\(login)")!

        session.dataTask(with: userDetailsURL, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    return
            }

            // Check decoding error & callback with failure
            guard let userDetails = try? JSONDecoder().decode(UserDetails.self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }

            // Callback with Success
            completion(Result.success(userDetails))
        }).resume()
    }
}
