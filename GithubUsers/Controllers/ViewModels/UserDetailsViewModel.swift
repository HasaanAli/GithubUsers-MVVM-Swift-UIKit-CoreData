//
//  UserDetailsViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation
import UIKit

protocol UserDetailsViewModelDelegate {
    func onDetailsSuccess(userDetails: UserDetails)
    func onDetailsFailed(error: DataResponseError)
}

/// View model for UserDetailsViewController.
class UserDetailsViewModel {
    let tag = "UserDetailsViewModel"
    let apiClient = GithubUsersClient.sharedInstance
    let coredataManager = CoreDataManager.sharedInstance

    var image: UIImage? {
        return userp.image
    }

    var notes: String {
        if let notesUser = userp as? NotesUser {
            return notesUser.notes
        } else {
            return ""
        }
    }

    private var userp: UserProtocol // because it can be reassigned with a different concreate type
    /// IndexPath of main table view to which this Details User belongs.
    let indexPath: IndexPath
    let delegate: UserDetailsViewModelDelegate

    init(userp: UserProtocol, at indexPath: IndexPath, delegate: UserDetailsViewModelDelegate) {
        self.userp = userp
        self.indexPath = indexPath
        self.delegate = delegate
    }

    func fetchDetails() {
        apiClient.fetchUserDetails(login: userp.login) { result in
            switch result {
            case .success(var userDetails):
                // set notes and image from local
                userDetails.image = self.image
                userDetails.notes = self.notes
                DispatchQueue.main.async {
                    self.delegate.onDetailsSuccess(userDetails: userDetails)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate.onDetailsFailed(error: error)
                }
            }
        }
    }

    func save(notes: String) {
        if notes.isEmpty {
            // If new notes are empty, assign DefaultUser to userp who doesn't have notes
            userp = User(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl, image: userp.image)
        } else {
            // If new notes are present, assign NotesUser to userp cz userp can be
            // a DefaultUser too who have notes
            userp = NotesUser(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl, notes: notes, image: userp.image)
        }
        // Now send the new userp to db
        coredataManager.update(userp: userp)
    }
}
