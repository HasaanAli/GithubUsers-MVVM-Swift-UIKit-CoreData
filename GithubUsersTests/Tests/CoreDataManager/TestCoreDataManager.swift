//
//  TestCoreDataManager.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import CoreData
import XCTest

class TestCoreDataManager: CoreDataManager {
    let tag = String(describing: TestCoreDataManager.self)

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

        // VERY IMPORTANT! so that test data doesnot get into sqlite db.
        // ! ! ! ! ! ! ! ! ! ! ! ! ! ! //
        persistentContainer = container
        // ! ! ! ! ! ! ! ! ! ! ! ! ! ! //
    }
}
