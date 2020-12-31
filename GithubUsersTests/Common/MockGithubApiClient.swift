//
//  MockGithubApiClient.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class MockGithubApiClient: GithubApiClient {
    var calledFetchUsers = false
    var fetchUsersExpectation: XCTestExpectation?
    var fetchUsersResult: Result<[User], DataResponseError>?

    override func fetchUsers(since: Int, perPage: Int, completion: @escaping (Result<[User], DataResponseError>) -> Void) {
        calledFetchUsers = true
        guard let result = fetchUsersResult else {
            XCTFail("Must set fetchUsersResult")
            return
        }
        completion(result)
        fetchUsersExpectation?.fulfill()
   }

    var calledFetchImage = false // TODO:
    var calledFetchImageWithUrlString: String?
    var fetchImageExpectation: XCTestExpectation?
    var fetchImageResult: Result<Data, DataResponseError>?

    override func fetchImage(urlString: String, completion: @escaping (Result<Data, DataResponseError>) -> Void) {
        calledFetchImage = true
        calledFetchImageWithUrlString = urlString
        guard let result = fetchImageResult else {
            XCTFail("Must set fetchImageResult")
            return
        }
        completion(result)
        fetchImageExpectation?.fulfill()
    }

    var calledFetchDetailsWithLogin: String?
    var fetchDetailsApiResult: Result<UserDetails, DataResponseError>?
    override func fetchUserDetails(login: String, completion: @escaping (Result<UserDetails, DataResponseError>) -> Void) {
        calledFetchDetailsWithLogin = login
        guard let result = fetchDetailsApiResult else {
            XCTFail("Must set fetchDetailsApiResult, returning")
            return
        }
        completion(result)
    }
}
