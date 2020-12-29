//
//  GithubUsersClient.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation
import Network

open class GithubUsersClient {
    let serialQueue = DispatchQueue(label: "ApiClientQueue")
    let dispatchGroup = DispatchGroup()

    private lazy var usersURL: URL = {
        return URL(string: "http://api.github.com/users")!
    }()

    let session: URLSession
    
    init(session: URLSession = URLSession.shared) { 
        self.session = session
    }
    
    func fetchUsers(since: Int, perPage: Int, completion: @escaping (Result<[User], DataResponseError>) -> Void) {
        serialQueue.async {
            NSLog("fetchUsers since: %d, perPage: %d", since, perPage)
            let urlRequest = URLRequest(url: self.usersURL)
            let parameters: [String : String] = ["per_page": "\(perPage)", "since": "\(since)"]
            let encodedURLRequest = urlRequest.encode(with: parameters)

            self.dispatchGroup.enter()
            self.session.dataTask(with: encodedURLRequest, completionHandler: { data, response, error in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.hasSuccessStatusCode,
                    let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    self.dispatchGroup.leave()
                    let nwpathMonitor = NWPathMonitor()
                    self.start(monitor: nwpathMonitor, pathUpdateHandler: { path in
                        if path.status == .satisfied {
                            self.fetchUsers(since: since, perPage: perPage, completion: completion)
                            nwpathMonitor.cancel() // after retrying once, further failure will retry itself
                        }
                    })

                    return
                }
                
                // Check decoding error & callback with failure
                guard let users = try? JSONDecoder().decode([User].self, from: data) else {
                    completion(Result.failure(DataResponseError.decoding))
                    self.dispatchGroup.leave()
                    return
                }
                
                // Callback with Success
                completion(Result.success(users))
                self.dispatchGroup.leave()
            }).resume()
            self.dispatchGroup.wait()
        }
    }

    func fetchImage(urlString: String, completion: @escaping (Result<Data, DataResponseError>) -> Void) {
        serialQueue.async {
            let imageUrl: URL = URL(string: urlString)!
            self.dispatchGroup.enter()
            self.session.downloadTask(with: imageUrl, completionHandler: { (location, urlResponse, error) -> Void in
                if let imageData = try? Data(contentsOf: imageUrl) {
                    completion(Result.success(imageData))
                } else {
                    NSLog("fetchImage download task: No data for image")
                    completion(Result.failure(DataResponseError.network))
                    let nwpathMonitor = NWPathMonitor()
                    self.start(monitor: nwpathMonitor, pathUpdateHandler: { path in
                        if path.status == .satisfied {
                            self.fetchImage(urlString: urlString, completion: completion)
                            nwpathMonitor.cancel() // after retrying once, further failure will retry itself
                        }
                    })
                }
                self.dispatchGroup.leave()
            }).resume()
            self.dispatchGroup.wait()
        }
    }

    func fetchUserDetails(login: String, completion: @escaping (Result<UserDetails, DataResponseError>) -> Void) {
        serialQueue.async {
            NSLog("fetchUserDetails login: %@", login)
            let userDetailsURL = URL(string: "http://api.github.com/users/\(login)")!

            self.dispatchGroup.enter()
            self.session.dataTask(with: userDetailsURL, completionHandler: { data, response, error in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.hasSuccessStatusCode,
                    let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    self.dispatchGroup.leave()
                    let nwpathMonitor = NWPathMonitor()
                    self.start(monitor: nwpathMonitor, pathUpdateHandler: { path in
                        if path.status == .satisfied {
                            self.fetchUserDetails(login: login, completion: completion)
                            nwpathMonitor.cancel() // after retrying once, further failure will retry itself
                        }
                    })
                    return
                }

                // Check decoding error & callback with failure
                guard let userDetails = try? JSONDecoder().decode(UserDetails.self, from: data) else {
                    completion(Result.failure(DataResponseError.decoding))
                    self.dispatchGroup.leave()
                    return
                }

                // Callback with Success
                completion(Result.success(userDetails))
                self.dispatchGroup.leave()
            }).resume()
            self.dispatchGroup.wait()
        }
    }
    private func start(monitor: NWPathMonitor, pathUpdateHandler: @escaping (NWPath) -> Void) {
        monitor.pathUpdateHandler = pathUpdateHandler
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
