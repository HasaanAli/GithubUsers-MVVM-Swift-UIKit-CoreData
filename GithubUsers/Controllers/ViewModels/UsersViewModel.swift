//
//  UsersViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

protocol UsersViewModelDelegate: AnyObject {
    func onCellViewModelsChanged()
    func onCellViewModelsUpdated(at indexPaths: [IndexPath])
    func onImageReady(at indexPath: IndexPath)
    func onNoDataChanged()
    /// Use retry() closure to be called when, for example, Internet becomes available.
    func onLoadFailed(with error: DataResponseError)
}

///View model for UsersViewController.
final class UsersViewModel {
    private let apiPageSize: Int
    /// Unfiltered array of cell view models. Use cellViewModel(at:) to get filtered cellViewModel, when applicable.
    private var ufCellViewModels: [UserCellViewModelProtocol]
    private var isFetchInProgress = false

    let coredataManager: CoreDataManager
    let apiClient: GithubApiClient
    weak var delegate: UsersViewModelDelegate?
    var imageCache = ImageCache.sharedInstance

    private var filteredCellViewModels: [UserCellViewModelProtocol]
    private var isFiltering = false
    
    var isFilteringg: Bool {
        return isFiltering
    }

    init(apiPageSize: Int, apiClient: GithubApiClient, coreDataManager: CoreDataManager) {
        self.apiPageSize = apiPageSize
        self.apiClient = apiClient
        self.coredataManager = coreDataManager
        ufCellViewModels = []
        filteredCellViewModels = []
    }

    /// Gives filtered count, when applicable.
    var currentCount: Int {
        if isFiltering {
            return filteredCellViewModels.count
        } else {
            return ufCellViewModels.count
        }
    }

    private var maxUserId: Int {
        return ufCellViewModels.last?.userp.id ?? 0
    }

    /// Gives filtered cellViewModel, when applicable.
    func cellViewModel(at index: Int) -> UserCellViewModelProtocol {
        if isFiltering {
            return filteredCellViewModels[index]
        } else {
            return ufCellViewModels[index]
        }
    }

    func loadData() {
        //Don't load if user is searching
        guard !isFiltering else {
            NSLog("Exiting loadData() because isFiltering.")
            return
        }

        // TODO: Use background queue, add hasData(since:), add limit to fetchAllUsers

        // load from database first time when ufCellViewModels array is empty
        if ufCellViewModels.count == 0, let dbUsers = coredataManager.fetchAllUsers(), dbUsers.count > 0 {
            var index = 0
            var missingImagesIndices = [Int]()
            for dbUser in dbUsers {
                // Store index if image missing
                if dbUser.image == nil {
                    missingImagesIndices.append(index)
                }

                switch dbUser {
                case let user as User:
                    ufCellViewModels.append(DefaultUserCellViewModel(user: user, index: index))
                    index += 1
                case let notesUser as NotesUser:
                    ufCellViewModels.append(NotesUserCellViewModel(notesUser: notesUser, index: index))
                    index += 1
                case let invertedUser as InvertedUser:
                    ufCellViewModels.append(InvertedUserCellViewModel(invertedUser: invertedUser, index: index))
                    index += 1
                default:
                    NSLog("UsersViewModel - loadData() Error: Failed dbUser switch cast as one of concrete types")
                }
            }
            DispatchQueue.main.async {
                self.delegate?.onCellViewModelsChanged()
            }
            // Load missing images here
            let indexPaths = missingImagesIndices.map { IndexPath(row: $0, section: 0) }
            loadImages(forUsersAtIndexPaths: indexPaths)

            //TODO: load from API too, in parallel, as required by the task.
        } else { // db gave nil or zero records
            loadUsersFromAPI()
        }
    }

    private func loadUsersFromAPI() {
        //Don't load if user is searching
        guard !isFiltering else {
            NSLog("Exiting loadUsersFromAPI() because isFiltering.")
            return
        }

        // if already in progress, exit early
        guard !isFetchInProgress else {
            return
        }

        // set in progress
        isFetchInProgress = true

        let lastMaxUserId = maxUserId
        let fetchUsersCompletionBlock: (Result<[User], DataResponseError>) -> Void = { result in
            switch result {
            case .failure(let error):
                self.isFetchInProgress = false
                DispatchQueue.main.async {
                    self.delegate?.onLoadFailed(with: error) // delegate shows appropriate UI for this error.
                }
            case .success(let newUsers):
                self.isFetchInProgress = false

                guard newUsers.count > 0 else { // we reached end of data
                    NSLog("loadUsersFromApi - success but no new user since=\(lastMaxUserId)")
                    DispatchQueue.main.async {
                        self.delegate?.onNoDataChanged()
                    }
                    return
                }
                // We have got new data

                // for inverted user cell view models, and for index passing in cell view model.
                var index = self.ufCellViewModels.count // Not 0

                for user in newUsers {
                    if index.isForth { // make inverted cell view model for every forth row
                        let invertedUser = InvertedUser(id: user.id, login: user.login, avatarUrl: user.avatarUrl, image: user.image)
                        let invertedUserCellViewModel = InvertedUserCellViewModel(invertedUser: invertedUser, index: index)
                        self.ufCellViewModels.append(invertedUserCellViewModel)
                    } else {
                        let defaultUserCellViewModel = DefaultUserCellViewModel(user: user, index: index)
                        self.ufCellViewModels.append(defaultUserCellViewModel)
                    }
                    index += 1
                }

                self.coredataManager.insert(users: newUsers) //Save to db.
                DispatchQueue.main.async {
                    self.delegate?.onCellViewModelsChanged()
                }
                let newIndexPaths = self.calculateIndexPathsToReload(appendCount: newUsers.count)
                self.loadImages(forUsersAtIndexPaths: newIndexPaths)
            }
        }
        apiClient.fetchUsers(since: lastMaxUserId, perPage: apiPageSize, completion: fetchUsersCompletionBlock)
    }

    /// Loads images from api.
    private func loadImages(forUsersAtIndexPaths indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let avatarUrl = cellViewModel(at: indexPath.row).userp.avatarUrl
            apiClient.fetchImage(urlString: avatarUrl) { result in
                switch result {
                case .success(let imageData):
                    if let image = UIImage(data: imageData) {
                        // Find the cellViewModel to update it with the image
                        var userp = self.ufCellViewModels[indexPath.row].userp
                        userp.image = image
                        self.ufCellViewModels[indexPath.row].userp = userp //update view model
                        self.imageCache.save(image: image, forKey: avatarUrl)
                        self.coredataManager.update(userp: userp) // update user image in db
                        DispatchQueue.main.async {
                            self.delegate?.onImageReady(at: indexPath)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.onLoadFailed(with: error)
                    }
                }
            }
        }
    }

    /// Call this method after appending new data to 'ufCellViewModels'.
    private func calculateIndexPathsToReload(appendCount: Int) -> [IndexPath] {
        let startIndex = ufCellViewModels.count - appendCount
        let endIndex = startIndex + appendCount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

    func update(notes: String, for cellViewModel: UserCellViewModelProtocol, at visibleIndexPath: IndexPath) {
        // Updating original unfiltered cellViewModel array is more important

        ///Unfiltered index
        let ufIndex = cellViewModel.unfilteredIndex
        let currentViewModel = ufCellViewModels[ufIndex]
        let userp = currentViewModel.userp

        let id = userp.id
        let login = userp.login
        let avatarUrl = userp.avatarUrl
        let image = userp.image
        
        // along the way, check isFiltering and update filtered array too
        
        if ufIndex.isForth { // make Inverted user, who may have notes
            let invertedUser = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, image: image, notes: notes)
            let invertedUserCellViewModel = InvertedUserCellViewModel(invertedUser: invertedUser, index: ufIndex)
            ufCellViewModels[ufIndex] = invertedUserCellViewModel
            if isFiltering {
                filteredCellViewModels[visibleIndexPath.row] = invertedUserCellViewModel
            }
        } else if notes.isEmpty { // make Default User, who doesn't have notes
            let user = User(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl, image: image)
            let defaultUserCellViewModel = DefaultUserCellViewModel(user: user, index: ufIndex)
            ufCellViewModels[ufIndex] = defaultUserCellViewModel
            if isFiltering {
                filteredCellViewModels[visibleIndexPath.row] = defaultUserCellViewModel
            }
        } else { // make NotesUser
            let notesUser = NotesUser(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl, notes: notes, image: image)
            let notesUserCellViewModel = NotesUserCellViewModel(notesUser: notesUser, index: ufIndex)
            ufCellViewModels[ufIndex] = notesUserCellViewModel
            if isFiltering {
                filteredCellViewModels[visibleIndexPath.row] = notesUserCellViewModel
            }
        }
        DispatchQueue.main.async {
            self.delegate?.onCellViewModelsUpdated(at: [visibleIndexPath])
        }
    }

    func filterData(by searchText: String) {
        isFiltering = !searchText.isEmpty
        filteredCellViewModels.removeAll()
        filteredCellViewModels = ufCellViewModels.filter {
            let loginContainsSearchText =  $0.userp.login.lowercased().contains(searchText.lowercased())
            var notesContainSearchText = false
            switch $0.userp {
            case let notesUser as NotesUser:
                notesContainSearchText = notesUser.notes.lowercased().contains(searchText.lowercased())
            case let invertedUser as InvertedUser:
                notesContainSearchText = invertedUser.notes.lowercased().contains(searchText.lowercased())
            default:
                break // No other userp has notes yet.
            }
            return loginContainsSearchText || notesContainSearchText
        }
        DispatchQueue.main.async {
            self.delegate?.onCellViewModelsChanged()
        }
    }
}
