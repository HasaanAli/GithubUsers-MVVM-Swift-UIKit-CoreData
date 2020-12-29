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
    func onLoadDetailsSuccess(userDetails: UserDetails)
    func onLoadDetailsFailed(error: DataResponseError)
    func onNotesChanged(to notes: String)
}

/// View model for UserDetailsViewController.
class UserDetailsViewModel {
    private let tag = "UserDetailsViewModel"
    var apiClient = AppDelegate.githubUsersClient
    var coredataManager = AppDelegate.coreDataManager


    var image: UIImage? {
        return tappedCellViewModel.userp.image
    }

    var notes: String {
        if let notesUser = tappedCellViewModel.userp as? NotesUser {
            return notesUser.notes
        } else if let invertedUser = tappedCellViewModel.userp as? InvertedUser {
            return invertedUser.notes
        } else if let detailedUser = tappedCellViewModel.userp as? UserDetails { // incase
            return detailedUser.notes
        } else { // DefaultUser doesn't have no notes
            return ""
        }
    }

    /// IndexPath of table row tapped by user.
    let tappedIndexPath: IndexPath // for visible index path

    // Derived property for public access
    var tappedCellViewModell: UserCellViewModelProtocol {
        return self.tappedCellViewModel
    }

    // var because it can be reassigned with a different concrete type depending upon new notes
    // Private so that no one can reassign from outside
    private var tappedCellViewModel: UserCellViewModelProtocol // for unfiltered index path
    
    let delegate: UserDetailsViewModelDelegate

    init(cellViewModel: UserCellViewModelProtocol, indexPath: IndexPath, delegate: UserDetailsViewModelDelegate) {
        self.tappedCellViewModel = cellViewModel
        self.tappedIndexPath = indexPath
        self.delegate = delegate
    }

    func fetchDetails() {
        apiClient.fetchUserDetails(login: tappedCellViewModel.userp.login) { result in
            switch result {
            case .success(var userDetails):
                // set notes and image from local
                userDetails.image = self.image
                userDetails.notes = self.notes
                DispatchQueue.main.async {
                    self.delegate.onLoadDetailsSuccess(userDetails: userDetails)
                }
            case .failure(let error):
                NSLog("%@ fetchDetails - error \(error)", self.tag)
                DispatchQueue.main.async {
                    self.delegate.onLoadDetailsFailed(error: error)
                }
            }
        }
    }

    func save(notes: String) {
        let notesNotEmpty = !notes.isEmpty
        let isForth = tappedCellViewModel.unfilteredIndex.isForth
        let oldUserp = tappedCellViewModel.userp
        let id = oldUserp.id
        let login = oldUserp.login
        let avatarUrl = oldUserp.avatarUrl
        let image = oldUserp.image

        // Create new userp
        switch (notesNotEmpty, isForth) {
        case (_, true): // make InvertedUser, may have notes
            tappedCellViewModel.userp = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, image: image, notes: notes)
        case (true, false): // make NotesUser
            tappedCellViewModel.userp = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes, image: image)
        case (false, false): // make DefaultUser
            tappedCellViewModel.userp = User(id: id, login: login, avatarUrl: avatarUrl, image: image)
        }
        // Now send the new userp to db
        coredataManager.update(userp: tappedCellViewModel.userp)
        // Call delegate
        delegate.onNotesChanged(to: notes)
    }
}
