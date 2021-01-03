//
//  UserDetailsViewModel.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/21/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import Foundation
import UIKit

protocol UserDetailsViewModelDelegate: AnyObject {
    func onLoadDetailsSuccess(userDetails: UserDetails)
    func onLoadDetailsFailed(error: DataResponseError)
    func onCellViewModelChanged(to userCellViewModel: UserCellViewModelProtocol)
}

/// View model for UserDetailsViewController.
class UserDetailsViewModel {
    private let tag = String(describing: UserDetailsViewModel.self)
    private let apiClient: GithubApiClient
    private let coredataManager: CoreDataManager

    var image: UIImage? {
        return tappedCellViewModel.userp.image
    }

    var notes: String {
        if let notesUser = currentCellViewModel.userp as? NotesUser {
            return notesUser.notes
        } else if let invertedUser = currentCellViewModel.userp as? InvertedUser {
            return invertedUser.notes
        } else if let detailedUser = currentCellViewModel.userp as? UserDetails { // incase
            return detailedUser.notes
        } else { // DefaultUser doesn't have notes
            return ""
        }
    }

    /// IndexPath of table row tapped by user.
    let tappedIndexPath: IndexPath // for visible index path

    // Can be either original tappedCellViewModel or a new cellViewModel after call to save(notes:) method.
    var currentCellViewModel: UserCellViewModelProtocol {
        return updatedCellViewModel ?? tappedCellViewModel
    }

    private let tappedCellViewModel: UserCellViewModelProtocol // for unfiltered index path
    private lazy var updatedCellViewModel: UserCellViewModelProtocol? = nil // for when notes change

    weak var delegate: UserDetailsViewModelDelegate?

    init(cellViewModel: UserCellViewModelProtocol, indexPath: IndexPath, apiClient: GithubApiClient, coredataManager: CoreDataManager) {
        self.tappedCellViewModel = cellViewModel
        self.tappedIndexPath = indexPath
        self.apiClient = apiClient
        self.coredataManager = coredataManager
    }

    func fetchDetails() {
        apiClient.fetchUserDetails(login: tappedCellViewModel.userp.login) { result in
            switch result {
            case .success(var userDetails):
                // set notes and image from local
                userDetails.image = self.image
                userDetails.notes = self.notes
                self.delegate?.onLoadDetailsSuccess(userDetails: userDetails)
            case .failure(let error):
                NSLog("%@ fetchDetails - error \(error)", self.tag)
                self.delegate?.onLoadDetailsFailed(error: error)
            }
        }
    }

    func save(notes: String) {
        guard notes != self.notes else {
            NSLog("%@ - save(notes:) - new notes '\(notes)' same as previous notes '\(self.notes)', returning", tag)
            return
        }

        let notesNotEmpty = !notes.isEmpty
        let unfilteredIndex = tappedCellViewModel.unfilteredIndex
        let oldUserp = tappedCellViewModel.userp
        let id = oldUserp.id
        let login = oldUserp.login
        let avatarUrl = oldUserp.avatarUrl
        let image = oldUserp.image

        // Create new userp
        switch (notesNotEmpty, unfilteredIndex.isForth) {
        case (_, true): // make InvertedUser, may have notes
            let invertedUser = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, image: image, notes: notes)
            updatedCellViewModel = InvertedUserCellViewModel(invertedUser: invertedUser, unfilteredIndex: unfilteredIndex)
        case (true, false): // make NotesUser
            let notesUser = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes, image: image)
            updatedCellViewModel = NotesUserCellViewModel(notesUser: notesUser, unfilteredIndex: unfilteredIndex)
        case (false, false): // make DefaultUser
            let user = User(id: id, login: login, avatarUrl: avatarUrl, image: image)
            updatedCellViewModel = DefaultUserCellViewModel(user: user, unfilteredIndex: unfilteredIndex)
        }

        guard let updatedCellViewModel = updatedCellViewModel else {
            NSLog("%@ - save(notes:) - updatedCellViewModel is nil, returning", tag)
            return
        }

        // Now send the new userp to db
        coredataManager.update(userp: updatedCellViewModel.userp)
        // Inform delegate
        delegate?.onCellViewModelChanged(to: updatedCellViewModel)
    }
}
