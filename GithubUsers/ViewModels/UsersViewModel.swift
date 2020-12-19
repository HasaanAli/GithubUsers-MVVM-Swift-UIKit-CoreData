//
//  UsersViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/19/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation

protocol UsersViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
}

final class UsersViewModel {
    private weak var delegate: UsersViewModelDelegate?

    private var users: [User] = []
    private var isFetchInProgress = false

    // TODO DB client TODO
    let client = GithubUsersClient()
    
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
        client.fetchUsers(since: lastMaxUserId) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.delegate?.onFetchFailed(with: error.description)
                }

            case .success(let newUsers):
                //TODO save to db
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
    
    private func calculateIndexPathsToReload(from newUsers: [User]) -> [IndexPath] {
        let startIndex = users.count - newUsers.count
        let endIndex = startIndex + newUsers.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}
