//
//  NotesUserTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//


@testable import GithubUsers
import XCTest

class NotesUserTests: XCTestCase {

    func testNotesUserConformsToUserProtocol() {
        let conforms = NotesUser.self is UserProtocol.Type
        XCTAssertTrue(conforms)
    }

    func testCreatingNotesUserWithParameterizedInit() {
        let id = 1
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"
        let user = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertEqual(user.notes, notes)
        XCTAssertNil(user.image)
    }

    func testCreatingNotesUserWithParameterizedInitImage() {
        let id = 1
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"
        let image = TestData.image

        let user = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes, image: image)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertEqual(user.notes, notes)
        XCTAssertNotNil(user.image)
        XCTAssertEqual(user.image!, image)
    }

    func testCreatingNotesUserWithEmptyNotes() {
        let id = 12
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let image = TestData.image

        let user = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: "", image: image)

        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.login, login)
        XCTAssertEqual(user.avatarUrl, avatarUrl)
        XCTAssertEqual(user.notes, "")
        XCTAssertNotNil(user.image)
        XCTAssertEqual(user.image!, image)
    }

    func testCreatingNotesUserWithNotesUser() {
        let id = 43
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let previousNotes = "oldnotes"
        let previousNotesUser = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: previousNotes)

        let newNotes = "somenewnotes"
        let notesUser = NotesUser(notesUser: previousNotesUser, withNotes: newNotes)

        XCTAssertEqual(notesUser.id, previousNotesUser.id)
        XCTAssertEqual(notesUser.login, previousNotesUser.login)
        XCTAssertEqual(notesUser.avatarUrl, previousNotesUser.avatarUrl)
        XCTAssertEqual(notesUser.notes, newNotes)
        XCTAssertNil(notesUser.image)
    }

    func testCreatingNotesUserWithNotesUserWithImage() {
        let id = 32
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let previousNotes = "oldnotes"
        let image = TestData.image
        let previousNotesUser = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: previousNotes, image: image)

        let newNotes = "somenewnotes"
        let notesUser = NotesUser(notesUser: previousNotesUser, withNotes: newNotes)

        XCTAssertEqual(notesUser.id, previousNotesUser.id)
        XCTAssertEqual(notesUser.login, previousNotesUser.login)
        XCTAssertEqual(notesUser.avatarUrl, previousNotesUser.avatarUrl)
        XCTAssertEqual(notesUser.notes, newNotes)
        XCTAssertNotNil(notesUser.image)
        XCTAssertNotNil(previousNotesUser.image)
        XCTAssertEqual(notesUser.image!, previousNotesUser.image!)
    }

    func testCreatingNotesUserWithUserWithImage() {
        let id = 34
        let login = "somelogin"
        let avatarUrl = "someavatarurl"
        let notes = "somenotes"
        let image = TestData.image
        let user = User(id: id, login: login, avatarUrl: avatarUrl, image: image)

        let notesUser = NotesUser(user: user, withNotes: notes)

        XCTAssertEqual(notesUser.id, user.id)
        XCTAssertEqual(notesUser.login, user.login)
        XCTAssertEqual(notesUser.avatarUrl, user.avatarUrl)
        XCTAssertNotNil(notesUser.image)

        if let notesUserImage = notesUser.image, let userImage = user.image { // must avoid force-unwrap in tests too.
            XCTAssertEqual(notesUserImage, userImage)
        } else {
            XCTFail()
        }
    }
}
