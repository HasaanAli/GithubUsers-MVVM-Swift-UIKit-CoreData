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
    private var apiPageSize: Int
    private var cellViewModels: [UserCellViewModelProtocol] = []
    private var isFetchInProgress = false

    let coredataManager = CoreDataManager.shared
    let apiClient = GithubUsersClient()
    let imageCache = ImageCache.shared

    init(delegate: UsersViewModelDelegate, apiPageSize: Int) {
        self.delegate = delegate
        self.apiPageSize = apiPageSize
    }

    var currentCount: Int {
        return cellViewModels.count
    }

    var maxUserId: Int {
        return cellViewModels.last?.userP.id ?? 0
    }

    func cellViewModel(at index: Int) -> UserCellViewModelProtocol {
        return cellViewModels[index]
    }

    func loadData() {
        // load from database first time when cellViewModels array is empty
        if cellViewModels.count == 0, let dbUsers = coredataManager.fetchAllUsers(), dbUsers.count > 0 {
            let defaultUserViewModels = dbUsers.map { DefaultUserViewModel(user: $0) }
            self.cellViewModels.append(contentsOf: defaultUserViewModels as [UserCellViewModelProtocol])
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
        apiClient.fetchUsers(since: lastMaxUserId, perPage: apiPageSize) { result in
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
                    let newDefaultUserViewModels = newUsers.map { DefaultUserViewModel(user: $0)} as [UserCellViewModelProtocol]
                    self.cellViewModels.append(contentsOf: newDefaultUserViewModels)
                    if self.maxUserId > lastMaxUserId {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: newUsers.count)
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
            var user = cellViewModel(at: indexPath.row).userP as! User
            let avatarUrl = user.avatarUrl
            apiClient.fetchImage(urlString: avatarUrl) { imageData in
                if let image = UIImage(data: imageData) {
                    user.image = image
                    self.cellViewModels[indexPath.row] = DefaultUserViewModel(user: user)
                    self.imageCache.save(image: image, forKey: avatarUrl)
                    DispatchQueue.main.async {
                        self.coredataManager.update(user: user) // update user image in db
                        self.delegate?.onImageReady(at: indexPath)
                    }
                }
            }
        }
    }

    private func calculateIndexPathsToReload(from newUsersCount: Int) -> [IndexPath] {
        let startIndex = cellViewModels.count - newUsersCount
        let endIndex = startIndex + newUsersCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
