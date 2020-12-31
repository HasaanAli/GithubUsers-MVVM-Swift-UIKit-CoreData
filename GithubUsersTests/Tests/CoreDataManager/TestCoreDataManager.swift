//
//  TestCoreDataManager.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 31/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import CoreData
import UIKit

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
                fatalError("Error at loading In-Memory store: \(error)")
            }
        }
        persistentContainer = container // Useful when we're testing core data stack itself
    }
}
