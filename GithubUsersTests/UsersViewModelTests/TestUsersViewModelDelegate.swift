//
//  TestUsersViewModelDelegate.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import Foundation

class TestUsersViewModelDelegate: UsersViewModelDelegate {
    var calledOnCellViewModelsChanged = false

    func onCellViewModelsChanged() {
        calledOnCellViewModelsChanged = true
    }

    func onCellViewModelsUpdated(at indexPaths: [IndexPath]) {

    }

    func onImageReady(at indexPath: IndexPath) {

    }

    func onNoDataChanged() {

    }

    func onLoadFailed(with error: DataResponseError) {

    }

    func reset() {
        calledOnCellViewModelsChanged = false
    }

}
