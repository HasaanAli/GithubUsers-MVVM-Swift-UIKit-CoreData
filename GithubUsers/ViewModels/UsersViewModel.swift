//
//  UsersViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation
import UIKit

protocol UsersViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onImageReady(at indexPath: IndexPath)
    func onFetchFailed(with reason: String)
}

final class UsersViewModel {
    private weak var delegate: UsersViewModelDelegate?

    private var users: [User] = []
    private var isFetchInProgress = false

    // TODO DB client TODO
    let apiClient = GithubUsersClient()
    let imageCache = ImageCache.shared
    
    init(delegate: UsersViewModelDelegate) {
        self.delegate = delegate
    }

    var currentCount: Int {
        return users.count
    }

    var maxUserId: Int {
        return users.last?.id ?? 0
    }

    func user(at index: Int) -> User {
        return users[index]
    }

    func loadUsers() {
        loadUsersFromDatabase()
        fetchUsersFromAPI()
    }

    private func loadUsersFromDatabase() {
        //TODO first load from DB
    }

    private func fetchUsersFromAPI() {
        // if already in progress, exit early
        guard !isFetchInProgress else {
            return
        }
        
        // set in progress
        isFetchInProgress = true

        let lastMaxUserId = maxUserId
        apiClient.fetchUsers(since: lastMaxUserId) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.description)
                }

            case .success(let newUsers):

                // TODO save to db
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    //let newUsers = newUsers
                    self.users.append(contentsOf: newUsers)
                    if self.maxUserId > lastMaxUserId {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: newUsers)
                        self.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.delegate?.onFetchCompleted(with: .none)
                    }
                }
            }
        }
    }

//     func loadImagesFromCache(forUsers users: [User]) {
//        for i in 0..<users.count {
//            var user = users[i]
//            if let avatar = imageCache.image(forKey: user.avatarUrl) {
//                user.image = avatar
//                self.delegate?.onImageReady(with: ...)
//            }
//
//        }
//    }

    /// Loads images from local cache or from api.
    func loadImages(forUsersAtIndexPaths indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let user = self.users[indexPath.row]
            let avatarUrl = user.avatarUrl
            if let avatar = imageCache.image(forKey: avatarUrl) { // available in cache
                users[indexPath.row].image = avatar
                self.delegate?.onImageReady(at: indexPath)
            } else { // fetch from api
                apiClient.fetchImage(urlString: avatarUrl) { imageData in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if let image = UIImage(data: imageData) {
                            self.users[indexPath.row].image = image
                            self.imageCache.save(image: image, forKey: avatarUrl)
                            self.delegate?.onImageReady(at: indexPath)
                        }
                    })
                }
            }
        }
    }
    
//    private func calculateRange(from newUsers: [User]) -> Range<Int> {
//        let startIndex = users.count - newUsers.count
//        let endIndex = startIndex + newUsers.count
//        return (startIndex..<endIndex)
//    }

    private func calculateIndexPathsToReload(from newUsers: [User]) -> [IndexPath] {
        let startIndex = users.count - newUsers.count
        let endIndex = startIndex + newUsers.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
