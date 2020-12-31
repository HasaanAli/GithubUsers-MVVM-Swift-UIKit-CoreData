//
//  TestCoreDataManager.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//


@testable import GithubUsers
import CoreData
import UIKit

class TestCoreDataManager: CoreDataManager {
    let tag = "TestCoreDataManager"

    override init() {
        super.init()
        // assign an in-memory persistent container
        let container = NSPersistentContainer(name: CoreDataManager.modelName)
        let inMemoryStoreDesc = NSPersistentStoreDescription()
        inMemoryStoreDesc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [inMemoryStoreDesc]
        container.loadPersistentStores { storeDesc, error in
            if let error = error as NSError? {
                fatalError("Error at loading In-Memory store: \(error)")
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

    override func insert(users: [UserProtocol]) {
        if lastInsertedUsers == nil {
            lastInsertedUsers = users
        } else { // twice insert detection
            lastInsertedUsers = nil
        }
    }

    var lastUpdatedUser: UserProtocol?
    var updatedUsersCount: Int = 0

    override func update(userp: UserProtocol) {
        lastUpdatedUser = userp
        updatedUsersCount += 1
    }
}
