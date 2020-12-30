//
//  TestGithubApiClient.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class TestGithubApiClient: GithubApiClient {
    var calledFetchUsers = false
    var fetchUsersExpectation: XCTestExpectation?
    var fetchUsersResult: Result<[User], DataResponseError>?

    override func fetchUsers(since: Int, perPage: Int, completion: @escaping (Result<[User], DataResponseError>) -> Void) {
        calledFetchUsers = true
        guard let result = fetchUsersResult else {
            fatalError("Must set fetchUsersResult")
        }
        completion(result)
        fetchUsersExpectation?.fulfill()
   }

    var calledFetchImage = false
    var calledFetchImageWithUrlString: String?
    var fetchImageExpectation: XCTestExpectation?
    var fetchImageResult: Result<Data, DataResponseError>?

    override func fetchImage(urlString: String, completion: @escaping (Result<Data, DataResponseError>) -> Void) {
        calledFetchImage = true
        calledFetchImageWithUrlString = urlString
        guard let result = fetchImageResult else {
            fatalError("Must set fetchImageResult")
        }
        completion(result)
        fetchImageExpectation?.fulfill()
    }
}
