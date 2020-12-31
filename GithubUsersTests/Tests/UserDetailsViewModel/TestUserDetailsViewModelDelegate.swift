//
//  TestUserDetailsViewModelDelegate.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 30/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class TestUserDetailsViewModelDelegate: UserDetailsViewModelDelegate {


    //var calledOnLoadDetailsSuccess = false
    let onLoadDetailsSuccessExpec = XCTestExpectation()
    var lastUserDetails: UserDetails?

    func onLoadDetailsSuccess(userDetails: UserDetails) {
        lastUserDetails = userDetails
        onLoadDetailsSuccessExpec.fulfill()
    }

    var calledOnLoadDetailsFailed = false
    var lastLoadDetailsFailedWithError: DataResponseError?

    func onLoadDetailsFailed(error: DataResponseError) {
        calledOnLoadDetailsFailed = true
        lastLoadDetailsFailedWithError = error
    }

    var calledOnCellViewModelChanged = false
    var lastCellViewModelChangedTo: UserCellViewModelProtocol?
    func onCellViewModelChanged(to userCellViewModel: UserCellViewModelProtocol) {
        calledOnCellViewModelChanged = true
        lastCellViewModelChangedTo = userCellViewModel
    }
}
