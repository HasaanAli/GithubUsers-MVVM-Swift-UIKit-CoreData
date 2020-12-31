//
//  InvertedUserTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class InvertedUserTests: XCTestCase {
    func testInvertedUserConformsToUserProtocol() {
        let conforms = InvertedUser.self is UserProtocol.Type
        XCTAssertTrue(conforms)
    }

    func testCreatingInvertedUserWithoutImageNotes() {
        let id = 54
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let user = InvertedUser(id: id, login: login, avatarUrl: avatarUrl)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNil(user.image)
        XCTAssertEqual(user.notes, "")
    }

    func testCreatingInvertedUserWithImage() {
        let id = 78
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let image = TestData.image

        let user = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, image: image)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNotNil(user.image)
        if let userImage = user.image {
            XCTAssertEqual(userImage, image)
        } else {
            XCTFail()
        }
        XCTAssertEqual(user.notes, "")
    }

    func testCreatingInvertedUserWithNotes() {
        let id = 11
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"

        let user = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNil(user.image)
        XCTAssertEqual(user.notes, notes)
    }

    func testCreatingInvertedUserWithNotesAndImage() {
        let id = 31
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"
        let image = TestData.image

        let user = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, image: image, notes: notes)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertNotNil(user.image)
        if let userImage = user.image {
            XCTAssertEqual(userImage, image)
        } else {
            XCTFail()
        }
        XCTAssertEqual(user.notes, notes)
    }

    //func test inverted image
}
