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
            return
        }
        completion(result)
        fetchUsersExpectation?.fulfill()
   }
}

extension TestGithubApiClient {
    static let apiUsersTestData: [User] = {
        var users = [User]()
        for i in 0..<10000 {
            users.append(User(id: i, login: "user\(i)login", avatarUrl: "user\(i)avatarurl"))
        }
        return users
    }()
}
