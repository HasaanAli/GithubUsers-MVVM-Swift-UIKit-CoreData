//
//  UsersViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UsersViewModelDelegate: class {
    func onFetchFromDBCompleted()
    func onFetchFromApiCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onImageReady(at indexPath: IndexPath)
    func onFetchFailed(with reason: String)
}

final class UsersViewModel {
    private weak var delegate: UsersViewModelDelegate?

    private var users: [User] = []
    private var isFetchInProgress = false

    let coredataManager = CoreDataManager.shared
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

    func loadData() {
        // load from database first time when users array is empty
        if users.count == 0, let dbUsers = coredataManager.fetchAllUsers(), dbUsers.count > 0 {
            self.users = dbUsers
            delegate?.onFetchFromDBCompleted()
        } else { // db gave nil or zero records
            loadUsersFromAPI()
        }
    }

    private func loadUsersFromAPI() {
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
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.coredataManager.insert(users: newUsers)
                    self.users.append(contentsOf: newUsers)
                    if self.maxUserId > lastMaxUserId {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: newUsers)
                        self.delegate?.onFetchFromApiCompleted(with: indexPathsToReload)
                    } else {
                        self.delegate?.onFetchFromApiCompleted(with: .none)
                    }
                }
            }
        }
    }

    /// Loads images from api.
    func downloadImages(forUsersAtIndexPaths indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            var user = self.users[indexPath.row]
            let avatarUrl = user.avatarUrl
            apiClient.fetchImage(urlString: avatarUrl) { imageData in
                if let image = UIImage(data: imageData) {
                    user.image = image
                    self.users[indexPath.row] = user
                    self.imageCache.save(image: image, forKey: avatarUrl)
                    DispatchQueue.main.async {
                        self.coredataManager.update(user: user) // update user image in db
                        self.delegate?.onImageReady(at: indexPath)
                    }
                }
            }
        }
    }

    private func calculateIndexPathsToReload(from newUsers: [User]) -> [IndexPath] {
        let startIndex = users.count - newUsers.count
        let endIndex = startIndex + newUsers.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
