//
//  GithubUsersTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import XCTest
@testable import GithubUsers

class UsersViewModelTests: XCTestCase {
    var calledOnCellViewModelsChanged: Bool = false

    override func setUp() {
        super.setUp()
        calledOnCellViewModelsChanged = false

    }

    func testFreshUsersViewModelCurrentCountIsZero() {
        let myUVMDel = MyUsersViewModelDelegate()
        let testViewModel = UsersViewModel(delegate: myUVMDel, apiPageSize: 5)
        XCTAssertEqual(testViewModel.currentCount, 0)
    }

    //MARK:- Data Loading Tests

    func testLoadDataCallsDatabaseFirst() {
        let myUVMDel = MyUsersViewModelDelegate()
        let testViewModel = UsersViewModel(delegate: myUVMDel, apiPageSize: 5)
        test
        testViewModel.loadData()
        XCTAssertEqual(testViewModel.currentCount, 0)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    class MyUsersViewModelDelegate: UsersViewModelDelegate {
        func onCellViewModelsChanged() {

        }

        func onCellViewModelsUpdated(at indexPaths: [IndexPath]) {

        }

        func onImageReady(at indexPath: IndexPath) {

        }

        func onNoDataChanged() {

        }

        func onLoadFailed(with error: DataResponseError) {

        }


    }

}
