//
//  UserDetailsTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class UserDetailsTests: XCTestCase {
    func testUserConformsToUserProtocol() {
         let conforms = UserDetails.self is UserProtocol.Type
         XCTAssertTrue(conforms)
     }

    func testDecodingFromJson() {
        //Arrange
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: "userdetails", withExtension: "json") else {
            XCTFail("Failed to locate file in bundle.")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load file from bundle.")
            return
        }

        // Act
        guard let userDetails = try? JSONDecoder().decode(UserDetails.self, from: data) else {
            XCTFail("Decoding json to [User] failed ")
            return
        }

        //Assert
        XCTAssertEqual(userDetails.id, 3121)
        XCTAssertEqual(userDetails.login, "jacob")
        XCTAssertEqual(userDetails.avatarUrl, "https://avatars1.githubusercontent.com/u/3121?v=4")
        XCTAssertEqual(userDetails.followers, 22)
        XCTAssertEqual(userDetails.following, 2)
        XCTAssertNil(userDetails.image)
        XCTAssertEqual(userDetails.notes, "")
    }

    func testCreatingUserDetailsWithParameterizedInit() {
        let id = 63
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let user = UserDetails(id: id, login: login, avatarUrl: avatarUrl)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNil(user.image)
        XCTAssertEqual(user.notes, "")
        XCTAssertNil(user.following)
        XCTAssertNil(user.followers)
    }
}
