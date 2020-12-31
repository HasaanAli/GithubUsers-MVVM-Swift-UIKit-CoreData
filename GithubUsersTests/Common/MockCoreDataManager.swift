//
//  MockCoreDataManager.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import CoreData
import XCTest

class MockCoreDataManager: CoreDataManager {
    let tag = "MockCoreDataManager"

    override init() {
        super.init()
        // assign an in-memory persistent container
        let container = NSPersistentContainer(name: CoreDataManager.modelName)
        let inMemoryStoreDesc = NSPersistentStoreDescription()
        inMemoryStoreDesc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [inMemoryStoreDesc]
        container.loadPersistentStores { storeDesc, error in
            if let error = error as NSError? {
                XCTFail("Error at loading In-Memory store: \(error)")
            }
        }
        persistentContainer = container // Useful when we're testing core data stack itself
    }

    var calledFetchAllUsers: Bool = false
    var fetchAllUsersFixture: [UserProtocol]?

    override func fetchAllUsers() -> [UserProtocol]? {
        calledFetchAllUsers = true
        return fetchAllUsersFixture
    }

    var lastInsertedUsers: [UserProtocol]?

    @discardableResult
    override func insert(users: [UserProtocol]) -> [UserEntity] {
        if lastInsertedUsers == nil {
            lastInsertedUsers = users
        } else { // twice insert detection
            lastInsertedUsers = nil
        }
        return [UserEntity]()
    }

    var lastUpdatedUser: UserProtocol?
    var updatedUsersCount: Int = 0

    override func update(userp: UserProtocol) -> UserEntity? {
        lastUpdatedUser = userp
        updatedUsersCount += 1
        return nil
    }
}
