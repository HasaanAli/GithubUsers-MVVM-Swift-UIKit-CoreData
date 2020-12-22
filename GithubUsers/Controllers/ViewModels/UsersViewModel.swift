//
//  UsersViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UsersViewModelDelegate: class {
    func onCellViewModelsChanged()
    func onCellViewModelsUpdated(at indexPaths: [IndexPath])
    func onImageReady(at indexPath: IndexPath)
    func onLoadFailed(with reason: String)
    func onNoDataChanged()
}

///View model for UsersViewController.
final class UsersViewModel {
    private weak var delegate: UsersViewModelDelegate?
    private let apiPageSize: Int
    private var cellViewModels: [UserCellViewModelProtocol] = []
    private var isFetchInProgress = false

    let coredataManager = CoreDataManager.sharedInstance
    let apiClient = GithubUsersClient.sharedInstance
    let imageCache = ImageCache.sharedInstance

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
            var newViewModelsCount = 0
            for dbUser in dbUsers {
                switch dbUser {
                case let user as User:
                    cellViewModels.append(DefaultUserCellViewModel(user: user))
                    newViewModelsCount += 1
                case let notesUser as NotesUser:
                    cellViewModels.append(NotesUserCellViewModel(notesUser: notesUser))
                    newViewModelsCount += 1
                case let invertedUser as InvertedUser:
                    cellViewModels.append(InvertedUserCellViewModel(invertedUser: invertedUser))
                    newViewModelsCount += 1
                default:
                    NSLog("UsersViewModel - loadData() Error: Failed dbUser switch cast as one of concrete types")
                }
            }
            delegate?.onCellViewModelsChanged()
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
                    self.delegate?.onLoadFailed(with: error.description)
                }
            case .success(let newUsers):
                self.isFetchInProgress = false

                guard newUsers.count > 0 else { // we reached end of data
                    NSLog("loadUsersFromApi - success but no new user since=\(lastMaxUserId)")
                    self.delegate?.onNoDataChanged()
                    return
                }
                // We got new data

                self.coredataManager.insert(users: newUsers) //Save to db.

                // Create new cell view models
                //                    var newUserCellViewModels = [UserCellViewModelProtocol]()
                var i = 0 // for inverted user cell view models
                for user in newUsers {
                    if i % 3 == 2 { // make inverted cell view model for every third row
                        let invertedUser = InvertedUser(id: user.id, login: user.login, avatarUrl: user.avatarUrl, image: user.image)
                        let invertedUserCellViewModel = InvertedUserCellViewModel(invertedUser: invertedUser)
                        self.cellViewModels.append(invertedUserCellViewModel)
                    } else {
                        let defaultUserCellViewModel = DefaultUserCellViewModel(user: user)
                        self.cellViewModels.append(defaultUserCellViewModel)
                    }
                    i += 1
                }

                DispatchQueue.main.async {
                    self.delegate?.onCellViewModelsChanged()
                }
                let newIndexPaths = self.calculateIndexPathsToReload(appendCount: newUsers.count)
                self.loadImages(forUsersAtIndexPaths: newIndexPaths)
            }
        }
    }

    /// Loads images from api.
    func loadImages(forUsersAtIndexPaths indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let avatarUrl = cellViewModel(at: indexPath.row).userP.avatarUrl
            apiClient.fetchImage(urlString: avatarUrl) { imageData in
                if let image = UIImage(data: imageData) {
                    // Find the cellViewModel to update it with the image
                    var userp = self.cellViewModels[indexPath.row].userP
                    userp.image = image
                    self.cellViewModels[indexPath.row].userP = userp //update view model
                    self.imageCache.save(image: image, forKey: avatarUrl)
                    self.coredataManager.update(userp: userp) // update user image in db

                    DispatchQueue.main.async {
                        self.delegate?.onImageReady(at: indexPath)
                    }
                }
            }
        }
    }

    /// Call this method after appending new data to 'cellViewModels'.
    private func calculateIndexPathsToReload(appendCount: Int) -> [IndexPath] {
        let startIndex = cellViewModels.count - appendCount
        let endIndex = startIndex + appendCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func updateCellViewModel(with notes: String, at indexPath: IndexPath) {
        // Replace the viewModel
        let currentViewModel = cellViewModel(at: indexPath.row)
        let userp = currentViewModel.userP
        if notes.isEmpty {
            var user = User(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl)
            user.image = userp.image
            cellViewModels[indexPath.row] = DefaultUserCellViewModel(user: user)
        } else {
            var notesUser = NotesUser(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl, notes: notes)
            notesUser.image = userp.image
            cellViewModels[indexPath.row] = NotesUserCellViewModel(notesUser: notesUser)
        }
        delegate?.onCellViewModelsUpdated(at: [indexPath])
    }
}
