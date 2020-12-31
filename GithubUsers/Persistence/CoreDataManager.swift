//
//  CoreDataManager.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/20/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    private let tag = "CoreDataManager"
    public static let modelName = "GithubUsers"
    static let userEntityName = "UserEntity"
    static let userEntityKey_Id = "id"

    ///Last time update(user:) was called.
    private var lastSaved: Date?

    init() {}

    open lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataManager.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                NSLog("%@ Unresolved error \(error), \(error.userInfo)", self.tag)
            }
        })
        return container
    }()

    lazy var readContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    lazy var writeContext: NSManagedObjectContext = {
        NSLog("%@ - Creating new background context ( write context )", tag)
        return persistentContainer.newBackgroundContext()
    }()

    /// Save changes if any. Use synchronously=true when calling from AppDelegate.didEnterBackground etc.
    func saveChangesIfAny(synchronously: Bool) {
        let saveWriteContext = {
            if self.writeContext.hasChanges {
                do {
                    try self.writeContext.save()
                    self.lastSaved = Date()
                    NSLog("%@ - Saved writeContext", self.tag)
                } catch let nserror as NSError {
                    NSLog("%@ - Failed at saveWriteContext() - \(nserror), \(nserror.userInfo)", self.tag)
                }
            }
        }
        if synchronously {
            writeContext.performAndWait { saveWriteContext() }
        } else {
            writeContext.perform { saveWriteContext() }
        }
    }

    /// Can be used from UI thread.
    @discardableResult
    func insert(users: [UserProtocol]) -> [UserEntity] {
        var entities: [UserEntity] = [UserEntity]()
        for userp in users {
            let userObject = UserEntity(context: self.writeContext)
            userObject.id = Int32(userp.id)
            userObject.login = userp.login
            userObject.avatarUrl = userp.avatarUrl
            if let image = userp.image {
                userObject.imageData = image.jpegDataBetter
            }
            if let notesUser = userp as? NotesUser {
                userObject.notes = notesUser.notes
            }
            entities.append(userObject)
        }

        NSLog("%@ - inserted users to writeContext")
        self.saveChangesIfAny(synchronously: false)

        return entities
    }

    func fetchAllUsers() -> [UserProtocol]? {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: CoreDataManager.userEntityName)

        let sortById = NSSortDescriptor(key: CoreDataManager.userEntityKey_Id, ascending: true)
        fetchRequest.sortDescriptors = [sortById]

        do {
            let userEntities = try readContext.fetch(fetchRequest)

            var users = [UserProtocol]()
            var i = 0 // for inverted users
            for userEntity in userEntities {
                let id = Int(userEntity.id)
                let login = userEntity.login
                let avatarUrl = userEntity.avatarUrl
                let imageData = userEntity.imageData
                let notes = userEntity.notes

                if let login = login, let avatarUrl = avatarUrl {
                    if i.isForth { // for inverted avatar
                        var user = InvertedUser(id: id, login: login, avatarUrl: avatarUrl)
                        user.image = imageData !=  nil ? UIImage(data: imageData!) : nil
                        user.notes = notes ?? ""
                        users.append(user)
                    } else if let notes = notes, !notes.isEmpty {
                        var notesUser = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: notes)
                        notesUser.image = imageData !=  nil ? UIImage(data: imageData!) : nil
                        users.append(notesUser)
                    } else {
                        var user = User(id: id, login: login, avatarUrl: avatarUrl)
                        user.image = imageData !=  nil ? UIImage(data: imageData!) : nil
                        users.append(user)
                    }
                }
                i += 1
            }
            NSLog("CoreDataManager.fetchAllUsers() Success. Count: \(users.count)")
            return users
        } catch let error as NSError {
            NSLog("CoreData - fetchAllUsers error: %@.", error)
            NSLog("CoreData - fetchAllUsers error.userInfo: %@.", error.userInfo)
            return nil
        }
    }

    func update(userp: UserProtocol) {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: CoreDataManager.userEntityName)
        let predicate = NSPredicate(format: "\(CoreDataManager.userEntityKey_Id) == %d", userp.id)
        fetchRequest.predicate = predicate

        do {
            let fetchedEntities = try self.writeContext.fetch(fetchRequest)

            guard fetchedEntities.count == 1 else {
                NSLog("%@ - ALARM !!! - update() fetched \(fetchedEntities.count) entities, returning", self.tag)
                return
            }

            guard let userEntity = fetchedEntities.first else {
                NSLog("%@ - update() - fetchedEntities.first is nil, returning", self.tag)
                return
            }

            userEntity.login = userp.login
            userEntity.avatarUrl = userp.avatarUrl
            if let image = userp.image {
                let imageData = image.jpegDataBetter
                userEntity.imageData = imageData
            }

            switch userp {
            case is User:
                userEntity.notes = nil
            case let invertedUser as InvertedUser:
                userEntity.notes = invertedUser.notes
            case let notesUser as NotesUser:
                userEntity.notes = notesUser.notes.isEmpty ? nil :  notesUser.notes
            default:
                NSLog("%@ - update() - switch userp default case run !!", self.tag)
            }
            NSLog("%@ - Updated userEntity", self.tag)
        } catch let error as NSError {
            NSLog("%@ update() - Failed. Error: \(error)", self.tag)
        }

        // Save changes if never saved or not saved in the last 30 seconds
        if self.lastSaved == nil || Date().timeIntervalSince(self.lastSaved!) > 30 {
            self.saveChangesIfAny(synchronously: false)
        }
        //        //Schedule auto save
        //        writeContext.perform(<#T##aSelector: Selector##Selector#>, with: <#T##Any?#>, afterDelay: <#T##TimeInterval#>)
    }

}
