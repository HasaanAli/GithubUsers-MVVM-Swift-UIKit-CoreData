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
    var testUVMDelegate = TestUsersViewModelDelegate()

    lazy var usersViewModel: UsersViewModel = {
        let uvm = UsersViewModel(
            apiPageSize: 5,
            apiClient: self.testApiClient,
            coreDataManager: self.testCoreDataManager)
        uvm.delegate = self.testUVMDelegate
        return uvm
    }()

    override func setUp() {
        super.setUp()
        testCoreDataManager = TestCoreDataManager()
        testApiClient = TestGithubApiClient()
        testUVMDelegate = TestUsersViewModelDelegate()

        usersViewModel = UsersViewModel(
            apiPageSize: 5,
            apiClient: testApiClient,
            coreDataManager: testCoreDataManager
        )
        usersViewModel.delegate = testUVMDelegate
    }

    //MARK:- Load from Db and API tests

    func testLoadsFromDatabaseFirstTime() {
        testCoreDataManager.fetchAllUsersFixture = CommonTestData.usersWithImages

        usersViewModel.loadData()

        assert(testCoreDataManager.calledFetchAllUsers)
        wait(for: [testUVMDelegate.onCellViewModelsChangedExpec], timeout: 0.1)
    }

    func testDoesnotLoadFromApiFirstTimeIfDBhasRecords() {
        testCoreDataManager.fetchAllUsersFixture = CommonTestData.usersWithImages

        usersViewModel.loadData()
        XCTAssertFalse(testApiClient.calledFetchUsers)
    }

    func testLoadsFromApiFirstTimeIfDBhasZeroRecords() {
        testCoreDataManager.fetchAllUsersFixture = [UserProtocol]()
        testApiClient.fetchUsersResult = ApiTestData.fetchUsersSuccessResult
        testApiClient.fetchImageResult = ApiTestData.fetchImageSuccessResult

        usersViewModel.loadData()
        assert(testApiClient.calledFetchUsers)
        wait(for: [testUVMDelegate.onCellViewModelsChangedExpec], timeout: 0.1)
    }

    func testLoadsFromApiIfLoadFromDatabaseFails() { // fetchAllUsers gives nil
        testCoreDataManager.fetchAllUsersFixture = nil
        testApiClient.fetchUsersResult = ApiTestData.fetchUsersSuccessResult
        testApiClient.fetchImageResult = ApiTestData.fetchImageSuccessResult

        usersViewModel.loadData()
        assert(testApiClient.calledFetchUsers)
        wait(for: [testUVMDelegate.onCellViewModelsChangedExpec], timeout: 0.1)
    }

    func testInsertsApiRecordsToDatabase() {
        let apiUsers: [User] = CommonTestData.defaultUsers
        testApiClient.fetchUsersResult = Result.success(apiUsers)
        testApiClient.fetchImageResult = ApiTestData.fetchImageSuccessResult

        usersViewModel.loadData()

        let insertedUsers = testCoreDataManager.lastInsertedUsers!
        XCTAssertEqual(insertedUsers.count, apiUsers.count)
        for i in 0..<apiUsers.count {
            XCTAssertEqual(insertedUsers[i].id, apiUsers[i].id)
            XCTAssertEqual(insertedUsers[i].login, apiUsers[i].login)
            XCTAssertEqual(insertedUsers[i].avatarUrl, apiUsers[i].avatarUrl)
            XCTAssertEqual(insertedUsers[i].image, apiUsers[i].image)
        }
    }

    func testLoadFromApiSecondTime() { // if first time database had records
        testCoreDataManager.fetchAllUsersFixture = [User(id: 1, login: "abc", avatarUrl: "some.url")]
        testApiClient.fetchUsersResult = ApiTestData.fetchUsersSuccessResult
        testApiClient.fetchImageResult = ApiTestData.fetchImageSuccessResult

        usersViewModel.loadData() // first time
        usersViewModel.loadData() // second time
        XCTAssert(testApiClient.calledFetchUsers)
    }

    // informs delegate when successfully loads 0 results from api
    func testSuccessfullyLoadingZeroResultsFromApi() {
        testApiClient.fetchUsersResult = Result.success([])
        usersViewModel.loadData()
        assert(testApiClient.calledFetchUsers)
        wait(for: [testUVMDelegate.onNoDataChangedExpec], timeout: 0.1)
    }

    // informs delegate when fails to load results from api due to network
    func testHandlesNetworkError() {
        let resultNetworkFailure: Result<[User], DataResponseError> = Result.failure(.network)
        testApiClient.fetchUsersResult = resultNetworkFailure
        usersViewModel.loadData()

        assert(testApiClient.calledFetchUsers)
        wait(for: [testUVMDelegate.onLoadFailedExpec], timeout: 0.1)

        switch resultNetworkFailure {
        case .failure(let failure):
            XCTAssertEqual(testUVMDelegate.lastOnLoadFailedError, failure)
        default:
            XCTFail()
        }
    }

    // informs delegate when fails to load results from api due to decoding
    func testHandlesDecodingError() {
        let resultDecodingFailure: Result<[User], DataResponseError> = Result.failure(.decoding)
        testApiClient.fetchUsersResult = resultDecodingFailure

        usersViewModel.loadData()

        assert(testApiClient.calledFetchUsers)
        wait(for: [testUVMDelegate.onLoadFailedExpec], timeout: 0.1)

        switch resultDecodingFailure {
        case .failure(let failure):
            XCTAssertEqual(testUVMDelegate.lastOnLoadFailedError, failure)
        default:
            XCTFail()
        }
    }

    // MARK:- Loading images tests

    func testDoesnotFetchImagesFromApiIfNoMissingImageInDatabaseUsers() {
        testCoreDataManager.fetchAllUsersFixture = CommonTestData.usersWithImages

        usersViewModel.loadData()
        wait(for: [testUVMDelegate.onCellViewModelsChangedExpec], timeout: 0.01)
        XCTAssertFalse(testApiClient.calledFetchImage) // TODO: wait verify not called
        // try inverting expectation
    }

    func testFetchImagesFromApiIfMissingImageInDatabaseUsers() {
//        let (missingImageUsers, missingImageIndices) = CommonTestData.dbUsersMissingImagesTestData
////        let (missingImageUsers, missingImageIndices) = ([User(id: 1, login: "login1", avatarUrl: "url1")], [0])
//        testCoreDataManager.fetchAllUsersFixture = missingImageUsers
//
//        let testImage = CommonTestData.image
//        let fetchImageSuccessResult: Result<Data, DataResponseError> = Result.success(testImage.jpegDataBetter!)
//        testApiClient.fetchImageResult = fetchImageSuccessResult
//
//
//        var calledOnImageReadyExpectation = XCTestExpectation(description: "called on image ready expectation")
//        testUVMDelegate.numberOfTimesCalledOnImageReady = 0
//        testUVMDelegate.onImageReadyExpectedCount = missingImageIndices.count
//        usersViewModel.loadData()
//        wait(for: [testUVMDelegate.calledOnImageReadyExpectation], timeout: 10)
////        let imagesReadyForIndexPaths = testUVMDelegate.calledOnImageReadyAtIndexPaths//.map { $0.row } // to rows
////        let predicate = NSPredicate(format: "count == %d", missingImageIndices.count)
////        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: testUVMDelegate.calledOnImageReadyAtIndexPaths)
////        wait(for: [expectation], timeout: 3)
//        XCTAssertEqual(testUVMDelegate.numberOfTimesCalledOnImageReady, missingImageIndices.count)
//
////        assert(testUVMDelegate.image)
////        XCTAssertFalse(testApiClient.calledFetchImage) // TODO: wait verify not called
    }

// MARK:- TODOs
    /**
    loadData() test cases:
    informs delegate when loads image from api
    informs delegate when fails to load image from api
    loads from api since max local user id
    loads data ordered by id
    loads all db data
    creates defaultUserCellViewModel for every user without notes // pull a method/refactor
    creates notesUserCellViewModel for every user with notes
    creates invertedCellViewModel for every 4th user
    loads all type of users, with/without notes
    */

    /**
     loading images:
     load images for results from db
     load image for results from api
        handles image loading network error
     loads missing images for results from db
     test retries loading image after network becomes available
     test retries loading api results after ...

     informs delegate when loads image from api
    informs delegate when fails to load image from api

     */
}
