//
//  ApiTestData.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 30/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import Foundation

class ApiTestData {
    static let fetchImageSuccessResult: Result<Data, DataResponseError> = Result.success(CommonTestData.image.jpegDataBetter!)
    static let fetchUsersSuccessResult: Result<[User], DataResponseError> = Result.success(CommonTestData.defaultUsers)
}
