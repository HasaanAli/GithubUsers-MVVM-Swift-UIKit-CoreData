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

    var testCoreDataManager = TestCoreDataManager()
    var testApiClient = TestGithubApiClient()
    lazy var usersViewModel = UsersViewModel(
        apiPageSize: 5,
        apiClient: testApiClient,
        coreDataManager: testCoreDataManager
    )

    override func setUp() {
        super.setUp()
        testCoreDataManager = TestCoreDataManager()
        testApiClient = TestGithubApiClient()
        usersViewModel = UsersViewModel(
            apiPageSize: 5,
            apiClient: testApiClient,
            coreDataManager: testCoreDataManager
        )
    }
    //MARK:- Load Data Tests

    /**
     loadData() test cases:
     1. loads from database first time
     2. doesn't load from api first-time if database has records
     3. load from api first time if database has 0 records
     4. stores API records to database
     5. loads second time from API, if first time database had records


     loads from api since max local user id
     stores API records to database

     loads data ordered by id
     loads all db data
     creates defaultUserCellViewModel for every user without notes
     creates notesUserCellViewModel for every user with notes
     creates invertedCellViewModel for every 4th user
     loads all type of users, with/without notes
     */

    func testLoadsFromDatabaseFirstTime() {
        usersViewModel.loadData()
        XCTAssert(testCoreDataManager.calledFetchAllUsers)
    }

    func testDoesnotLoadFromApiFirstTimeIfDBhasRecords() {
        testCoreDataManager.fetchAllUsersFixture = [User(id: 1, login: "abc", avatarUrl: "some.url")]

        usersViewModel.loadData()
        XCTAssertFalse(testApiClient.calledFetchUsers)
    }

    func testLoadsFromApiFirstTimeIfDBhasZeroRecords() {
        usersViewModel.loadData()
        XCTAssert(testApiClient.calledFetchUsers)
    }


    func testStoresApiRecordsToDatabase() {
        let apiUsers: [User] = TestGithubApiClient.apiUsersTestData
        testApiClient.fetchUsersResult = Result.success(apiUsers)
//        testApiClient.fetchUsersExpectation = XCTestExpectation(description: "fetchUsers expectation")

        usersViewModel.loadData()
//        wait(for: [testApiClient.fetchUsersExpectation!], timeout: 1)

        let insertedUsers = testCoreDataManager.insertedUsersFixture!
        XCTAssertEqual(insertedUsers.count, apiUsers.count)
        for i in 0..<apiUsers.count {
            XCTAssertEqual(insertedUsers[i].id, apiUsers[i].id)
            XCTAssertEqual(insertedUsers[i].login, apiUsers[i].login)
            XCTAssertEqual(insertedUsers[i].avatarUrl, apiUsers[i].avatarUrl)
            XCTAssertEqual(insertedUsers[i].image, apiUsers[i].image)
        }
    }

    func testLoadFromApiSecondTime() { // if first time database had records
//        let testCoreDataManager = TestCoreDataManager()
        testCoreDataManager.fetchAllUsersFixture = [User(id: 1, login: "abc", avatarUrl: "some.url")]
//        usersViewModel.coredataManager = testCoreDataManager

//        let testApiClient = TestGithubApiClient()
//        usersViewModel.apiClient = testApiClient

        usersViewModel.loadData() // first time
        usersViewModel.loadData() // second time
        XCTAssert(testApiClient.calledFetchUsers)
    }

    // MARK:- Search data

    /**
     search test cases
     filtering becomes active when filtered with a non-empty string
     filtering becomes inactive when filtered with an empty string
     1. data is filtered by user login (case insensitive, contains)
     2. data is filtered by user login (case insensitive, exact match)
     3. data is filtered by user notes (case insensitive, contains)
     4. data is filtered by user notes (case insensitive, exact match)

     5. doesn't load more data while user is searching through it
     */

    func testFilterByUserLogin() {
        let users: [UserProtocol] =
            [User(id: 1, login: "user1login", avatarUrl: "user1url"),
             NotesUser(id: 2, login: "user2login", avatarUrl: "someurl", notes: "user2notes")]

//        let testCoreDataManager = TestCoreDataManager()
        testCoreDataManager.fetchAllUsersFixture = users
//        usersViewModel.coredataManager = testCoreDataManager
        usersViewModel.loadData()

        usersViewModel.filterData(by: "Ser1LOG")
        //        assert(usersViewModel.cellViewModel(at: 0))

    }

    override func tearDown() {
        super.tearDown()

    }

    func todotestPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
