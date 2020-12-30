//
//  TestCoreDataManager.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 29/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import CoreData
@testable import GithubUsers

class TestCoreDataManager: CoreDataManager {
    let tag = "TestCoreDataManager"
    var calledFetchAllUsers: Bool = false
    var fetchAllUsersFixture: [UserProtocol]?

    var insertedUsersFixture: [UserProtocol]?

    override init() {
        super.init()
        // assign an in-memory persistent container
        let container = NSPersistentContainer(name: CoreDataManager.modelName)
        let inMemoryStoreDesc = NSPersistentStoreDescription()
        inMemoryStoreDesc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [inMemoryStoreDesc]
        container.loadPersistentStores { storeDesc, error in
            if let error = error as NSError? {
                fatalError("Error at loading store In-Memory store: \(error)")
            }
        }
        persistentContainer = container
    }

    override func fetchAllUsers() -> [UserProtocol]? {
        calledFetchAllUsers = true
        return fetchAllUsersFixture
    }

    override func insert(users: [UserProtocol]) {
        insertedUsersFixture = users
    }
}
