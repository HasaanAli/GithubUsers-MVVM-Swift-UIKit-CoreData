//
//  UserTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class UserTests: XCTestCase {
    func testUserConformsToUserProtocol() {
         let conforms = User.self is UserProtocol.Type
         XCTAssertTrue(conforms)
     }

    func testDecodingFromJson() {
        //Arrange
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: "users", withExtension: "json") else {
            XCTFail("Failed to locate file in bundle.")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load file from bundle.")
            return
        }

        // Act

        guard let users = try? JSONDecoder().decode([User].self, from: data) else {
            XCTFail("Decoding json to [User] failed ")
            return
        }

        //Assert
        XCTAssertEqual(users.count, 30)
        let user = users[0]
        XCTAssertEqual(user.id, 3)
        XCTAssertEqual(user.login, "pjhyett")
        XCTAssertEqual(user.avatarUrl, "https://avatars0.githubusercontent.com/u/3?v=4")
    }

    func testCreatingUserWithParameterizedInit() {
        let id = 1
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let user = User(id: id, login: login, avatarUrl: avatarUrl)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNil(user.image)
    }

    func testCreatingUserWithParameterizedInitImage() {
        let id = 1
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let image = TestData.image

        let user = User(id: id, login: login, avatarUrl: avatarUrl, image: image)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNotNil(user.image)
        if let userImage = user.image {
            XCTAssertEqual(userImage, image)
        } else {
            XCTFail()
        }
    }

    func testCreatingUserWithNotesUser() {
        let id = 1
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"
        let notesUser = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes)

        let user = User(notesUser: notesUser)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNil(user.image)
    }

    func testCreatingUserWithNotesUserWithImage() {
        let id = 34
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"
        let image = TestData.image
        let notesUser = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes, image: image)

        let user = User(notesUser: notesUser)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNotNil(user.image)
        if let userImage = user.image {
            XCTAssertEqual(userImage, image)
        } else {
            XCTFail()
        }
    }
}
