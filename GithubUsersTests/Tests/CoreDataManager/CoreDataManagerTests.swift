//
//  CoreDataManagerTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class CoreDataManagerTests: XCTestCase {

    var testCoreDataManager: TestCoreDataManager!

    // Keeping implicit-optional data member instead of in-line initialization is because
    // otherwise for some reason 1 test '' always fail when whole test class is run

    override func setUp() {
        super.setUp()
        testCoreDataManager = TestCoreDataManager() // VERY IMPORTANT
    }

    // MARK:- Insert tests

    func testInsertDefaultUser() { // We don't insert other type of users right now
        let defaultUsers = TestData.defaultUsers(startId: 0, count: 10)

        //Act
        let userEntities = testCoreDataManager.insert(users: defaultUsers)

        //Assert
        XCTAssertEqual(userEntities.count, defaultUsers.count)

        var entity: UserEntity
        var user: User
        for i in 0..<userEntities.count {
            user = defaultUsers[i]
            entity = userEntities[i]

            XCTAssertEqual(entity.id, Int32(user.id))
            XCTAssertEqual(entity.login, user.login)
            XCTAssertEqual(entity.avatarUrl, user.avatarUrl)
            XCTAssertNil(entity.notes)
            XCTAssertNil(entity.imageData)
        }
    }

    // We don't insert other type of users in the main app right now, so specific tests for their insertion

    func testInsertionAlsoSaves() {
        let defaultUsers = TestData.defaultUsers
        //Act
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: defaultUsers)

        //Assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }

    // MARK:- Fetch tests

    func testFetchChangesAny4thUserToInvertedUser() { // with or without notes
        let defaultUsers = TestData.defaultUsers(startId: 0, count: 10)
        let notesUsers = TestData.notesUsers(startId: 10, count: 10)
        let users: [UserProtocol] = (defaultUsers + notesUsers).shuffled()
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: users)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        guard let fetchedUsers = testCoreDataManager.fetchAllUsers() else {
            XCTFail("fetchAllUsers returned nil")
            return
        }

        for i in 0..<20 {
            let user = fetchedUsers[i] as? InvertedUser
            if i%4 == 3 {
                XCTAssertNotNil(user)
            } else {
                XCTAssertNil(user)
            }
        }
    }

    func testFetchSortsById() {
        let users = TestData.defaultUsers(startId: 0, count: 20).shuffled()
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: users)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        guard let fetchedUsers = testCoreDataManager.fetchAllUsers() else {
            XCTFail("fetchAllUsers returned nil")
            return
        }

        for i in 1..<20 { // notice starting from 0
            XCTAssertLessThan(fetchedUsers[i-1].id, fetchedUsers[i].id)
        }
    }

    func testFetchChangesEachNon4thUserWithNotesToNotesUser() {
        let defaultUsers = TestData.defaultUsers(startId: 0, count: 10)
        let notesUsers = TestData.notesUsers(startId: 10, count: 10)
        let users: [UserProtocol] = (defaultUsers + notesUsers).shuffled()
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: users)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        // Act/Assert
        guard let fetchedUsers = testCoreDataManager.fetchAllUsers() else {
            XCTFail("fetchAllUsers returned nil")
            return
        }

        // filter all NotesUser first
        let fetchedUsersFiltered = fetchedUsers.filter { userp in
            return (userp as? NotesUser) != nil
        }
        guard let filteredNotesUsers = fetchedUsersFiltered as? [NotesUser] else {
            XCTFail("fetchedUsersFiltered failed cast as [NotesUser].")
            return
        }

        // then verify count. there were 10 notes user with ids 10 to 19.
        // ids 11, 15, 19 should have become Inverted Users
        // so filtered notes users count should be 10-3 = 7

        XCTAssertEqual(filteredNotesUsers.count, 7)

        // then match each filtered NotesUser with original notesUsers inserted

        let expectedNotesUsersIds = [10,12,13,14,16,17,18]
        let expectedNotesUsers = notesUsers.filter { expectedNotesUsersIds.contains($0.id) }

        for i in 0..<7 {
            XCTAssertEqual(filteredNotesUsers[i], expectedNotesUsers[i])
        }
    }

    func testFetchChangesEachNon4thUserWithEmptyNotesToDefaultUser() {
        let notesUsersWithEmptyNotes: [NotesUser] = {
            let defaultUsers = TestData.defaultUsers(startId: 0, count: 10)
            return defaultUsers.map { NotesUser(user: $0, withNotes: "") }
        }()

        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: notesUsersWithEmptyNotes)

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        // Act/Assert
        guard let fetchedUsers = testCoreDataManager.fetchAllUsers() else {
            XCTFail("fetchAllUsers returned nil, stopping testcase")
            return
        }

        // filter all DefaultUser first, because some users would have become InvertedUser.
        let fetchedUsersFiltered = fetchedUsers.filter { userp in
            return (userp as? User) != nil
        }
        guard let fetchedDefaultUsers = fetchedUsersFiltered as? [User] else {
            XCTFail("fetchedUsersFiltered failed cast as [User], stopping testcase")
            return
        }

        //Inserted empty notes users were 10 having ids 0 to 9. Ids 3, 7 are forth users (Inverted) so remaining we should have 8 users.
        XCTAssertEqual(fetchedDefaultUsers.count, 8)

        // then match each default user with original notesUsers inserted

        let expectedUsers: [User] = {
            let filtered = notesUsersWithEmptyNotes.filter { $0.id != 3 && $0.id != 7 } // 3,7 id users should have become InvertedUser
            let filteredDefaultUsers = filtered.map { User(notesUser: $0) }
            return filteredDefaultUsers
        }()

        for i in 0..<8 {
            XCTAssertEqual(fetchedDefaultUsers[i], expectedUsers[i])
        }
    }

    func testFetchBringsImagesToo() {
        let defaultUsersWithImage = TestData.defaultUsers(startId: 0, count: 3, withImage: true)
        let notesUsersWithImage = TestData.notesUsers(startId: 0, count: 3, withImage: true)
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: (defaultUsersWithImage + notesUsersWithImage))

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        //Act/assert
        guard let fetchedUsers = testCoreDataManager.fetchAllUsers() else {
            XCTFail("fetched nil, stopping test")
            return
        }

        // Image -> Data (when inserted)
        // Data -> Image (when fetched)
        let insertedData = TestData.image.jpegDataBetter!
        let createdImage: UIImage = UIImage(data: insertedData)!
        for i in 0..<6 {
            XCTAssertEqual(fetchedUsers[i].image?.jpegDataBetter!, createdImage.jpegDataBetter!)
        }
    }

    // MARK:- Update tests

    func testUpdateStopsIfNoUserExistsWithGivenId() {
        let user = User(id: 1, login: "somelogin", avatarUrl: "someurl")
        let userEntity = testCoreDataManager.update(userp: user)
        XCTAssertNil(userEntity)
    }

    func testUpdateStopsIfMoreThan1UsersExistWithGivenId() {
        let user1 = User(id: 11, login: "somelogin", avatarUrl: "someurl")
        let user2 = User(id: 11, login: "somelogin", avatarUrl: "someurl")

        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: [user1, user2])

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        let userEntity = testCoreDataManager.update(userp: user1)
        XCTAssertNil(userEntity)
    }

    func testUpdateWorksIfExactly1UserExistsWithGivenId() {
        let sameId = 11
        let user1 = NotesUser(id: sameId, login: "somelogin", avatarUrl: "someurl", notes: "somenotes")

        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: [user1])

        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        let updatedUser = User(id: sameId, login: "some new login", avatarUrl: "somenewavatarurl", image: TestData.image)

        // Act/assert
        guard let userEntity = testCoreDataManager.update(userp: updatedUser) else {
            XCTFail("update(userp:) returned nil unexpectedly")
            return
        }

        XCTAssertEqual(userEntity.id, Int32(updatedUser.id))
        XCTAssertEqual(userEntity.login, updatedUser.login)
        XCTAssertEqual(userEntity.avatarUrl, updatedUser.avatarUrl)
        XCTAssertEqual(userEntity.imageData, TestData.image.jpegDataBetter)
        XCTAssertNil(userEntity.notes)
    }

    func testSuccessfulUpdateTriggersSave() { // we'll change autoupdate time interval before calling update(userp:)
        let sameId = 11
        let user1 = NotesUser(id: sameId, login: "somelogin", avatarUrl: "someurl", notes: "somenotes")

        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }

        testCoreDataManager.insert(users: [user1])

        // First, let the insert save notification get triggered
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        // expectation for update()
        expectation(forNotification: .NSManagedObjectContextDidSave,
                    object: testCoreDataManager.writeContext) { _ in
            return true
        }
        testCoreDataManager.onUpdateAutoSaveTimeInterval = 0 // Change default interval

        let updatedUser = User(id: sameId, login: "some new login", avatarUrl: "somenewavatarurl", image: TestData.image)

        // Act/assert
        guard let _ = testCoreDataManager.update(userp: updatedUser) else {
            XCTFail("update(userp:) returned nil unexpectedly")
            return
        }

        // Now, wait for the context save notification due to update() call.
        waitForExpectations(timeout: 0.5) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }

    // MARK:- Todos
    /**
     TODOs:
     test insert detects/skips duplicate id users
     */
}
