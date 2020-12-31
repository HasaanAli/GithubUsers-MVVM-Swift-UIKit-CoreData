//
//  UsersViewModelFilterDataTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 30/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class UsersViewModelFilterDataTests: XCTestCase {
    let image = TestData.image
    lazy var users: [UserProtocol] =
        [User(id: 1, login: "user1login", avatarUrl: "user1url", image: image),
         NotesUser(id: 2, login: "Xuser2login", avatarUrl: "user2url", notes: "user2notes", image: image),
         InvertedUser(id: 3, login: "user3login", avatarUrl: "someurl", image: image, notes: "Xuser3notes")]
    var mockCoreDataManager = MockCoreDataManager()
    var mockApiClient = MockGithubApiClient()
    var testUVMDelegate = TestUsersViewModelDelegate()
    lazy var usersViewModel: UsersViewModel = {
        let uvm = UsersViewModel(
            apiPageSize: 5,
            apiClient: self.mockApiClient,
            coreDataManager: self.mockCoreDataManager)
        uvm.delegate = self.testUVMDelegate
        return uvm
    }()

    override func setUp() {
        super.setUp()
        mockCoreDataManager.fetchAllUsersFixture = users
        usersViewModel.loadData()
        wait(for: [testUVMDelegate.onCellViewModelsChangedExpec], timeout: 0.1) // due to loadData
    }

    func testFilterNoUser() {
        usersViewModel.filterData(by: "Ser1NOT")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 0)
    }

    func testFilter1UserByLogin() {
        usersViewModel.filterData(by: "Ser1LOG")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 1)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! User, users[0] as! User)
    }

    func testFilter1NotesUserByLogin() {
        usersViewModel.filterData(by: "user2login")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 1)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! NotesUser, users[1] as! NotesUser)
    }

    func testFilter1InvertedUserByLogin() {
        usersViewModel.filterData(by: "3Log")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 1)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! InvertedUser, users[2] as! InvertedUser)
    }

    func testFilter1NotesUserByNotes() {
        usersViewModel.filterData(by: "user2notes")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 1)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! NotesUser, users[1] as! NotesUser)
    }

    func testFilter1InvertedUserByNotes() {
        usersViewModel.filterData(by: "3NoT")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 1)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! InvertedUser, users[2] as! InvertedUser)
    }

    func testFilter1UserByBothLoginAndNotes() {
        usersViewModel.filterData(by: "Ser2")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 1)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! NotesUser, users[1] as! NotesUser)
    }

    func testFilter2Users1ByLogin1ByNotes() {
        usersViewModel.filterData(by: "XuSer")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 2)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! NotesUser, users[1] as! NotesUser)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 1).userp as! InvertedUser, users[2] as! InvertedUser)
    }


    func testFinishSearchByEmptyString() {
        usersViewModel.filterData(by: "")
        XCTAssertFalse(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 3)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! User, users[0] as! User)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 1).userp as! NotesUser, users[1] as! NotesUser)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 2).userp as! InvertedUser, users[2] as! InvertedUser)
    }
    
    func testFilterAllUsersByLogin() {
        usersViewModel.filterData(by: "LOGi")
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 3)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! User, users[0] as! User)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 1).userp as! NotesUser, users[1] as! NotesUser)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 2).userp as! InvertedUser, users[2] as! InvertedUser)
    }

    func testFilterAllUsersSomeByLoginSomeByNotes() {
        usersViewModel.filterData(by: "SER") //
        assert(usersViewModel.isFilteringg)
        XCTAssertEqual(usersViewModel.currentCount, 3)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 0).userp as! User, users[0] as! User)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 1).userp as! NotesUser, users[1] as! NotesUser)
        XCTAssertEqual(usersViewModel.cellViewModel(at: 2).userp as! InvertedUser, users[2] as! InvertedUser)
    }

    /**
     TODO:
     - doesn't load more data while user is searching through it
     */
}
