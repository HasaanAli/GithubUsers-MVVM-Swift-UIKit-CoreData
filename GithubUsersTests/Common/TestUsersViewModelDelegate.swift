//
//  TestUsersViewModelDelegate.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import Foundation
import XCTest

class TestUsersViewModelDelegate: UsersViewModelDelegate {
    // MARK:-

    let onCellViewModelsChangedExpec = XCTestExpectation(description: "onCellViewModelsChangedExpec")

    func onCellViewModelsChanged() {
        onCellViewModelsChangedExpec.fulfill()
    }

    // MARK:-

    var calledOnCellViewModelsUpdated = false
    var lastOnCellViewModelsUpdatedIndexPaths: [IndexPath]?
    let onCellViewModelsUpdatedExpec = XCTestExpectation(description: "onCellViewModelsUpdatedExpec")

    func onCellViewModelsUpdated(at indexPaths: [IndexPath]) {
        calledOnCellViewModelsUpdated = true
        lastOnCellViewModelsUpdatedIndexPaths = indexPaths
        onCellViewModelsUpdatedExpec.fulfill()
    }

    // MARK:-

    var calledOnImageReady = false
    var calledOnImageReadyAtIndexPaths: [IndexPath] = [IndexPath]()
    var onImageReadyCount: Int = 0
    var onImageReadyExpectedCount: Int?
    lazy var onImageReadyExpectation: XCTNSPredicateExpectation? = {
        if let expectedCount = self.onImageReadyExpectedCount {
            return XCTNSPredicateExpectation(predicate: NSPredicate(format: "self == %d", expectedCount),
                                             object: onImageReadyCount)
        } else {
            return nil
        }
    }()

    func onImageReady(at indexPath: IndexPath) {
        calledOnImageReady = true
        calledOnImageReadyAtIndexPaths.append(indexPath)
        onImageReadyCount += 1 // when it reaches expected count, the expectation will fulfill
    }

    // MARK:-

    let onNoDataChangedExpec = XCTestExpectation()

    func onNoDataChanged() {
        onNoDataChangedExpec.fulfill()
    }

    // MARK:-

    var calledOnLoadFailed = false
    var lastOnLoadFailedError: DataResponseError?
    let onLoadFailedExpec = XCTestExpectation()

    func onLoadFailed(with error: DataResponseError) {
        calledOnLoadFailed = true
        lastOnLoadFailedError = error
        onLoadFailedExpec.fulfill()
    }
}
