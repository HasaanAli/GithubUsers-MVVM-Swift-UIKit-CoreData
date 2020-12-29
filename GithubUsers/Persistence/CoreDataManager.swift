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
    static let userEntityKey_Login = "login"
    static let userEntityKey_AvatarUrl = "avatarUrl"
    static let userEntityKey_ImageData = "imageData"
    static let userEntityKey_Notes = "notes"

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

    /// Uses performAndWait and writeContext.hasChanges to save writeContext.
    func saveWriteContext() {
        /**
         Use performAndWait so that if AppDelegate calls us from within, for example, appWillTerminate, then we should wait and save the context changes.
         */
        writeContext.performAndWait {
            if self.writeContext.hasChanges {
                do {
                    try self.writeContext.save()
                    NSLog("%@ - Saved writeContext", self.tag)
                } catch let nserror as NSError {
                    NSLog("%@ - Failed at saveWriteContext() - \(nserror), \(nserror.userInfo)", self.tag)
                }
            }
        }
    }

    /// Can be used from UI thread.
    func insert(users: [UserProtocol]) {
        for userp in users {
            let entity = NSEntityDescription.entity(forEntityName: CoreDataManager.userEntityName, in: writeContext)!
            let userObject = NSManagedObject(entity: entity, insertInto: writeContext)
            if let userEntity = userObject as? UserEntity {
                print("insert - cast to UserEntity successful")
            } else {
                print("insert - cast to UserEntity failed")
            }

            userObject.setValue(userp.id, forKeyPath: CoreDataManager.userEntityKey_Id)
            userObject.setValue(userp.login, forKeyPath: CoreDataManager.userEntityKey_Login)
            userObject.setValue(userp.avatarUrl, forKeyPath: CoreDataManager.userEntityKey_AvatarUrl)
            if let image = userp.image {
                let imageData = image.jpegData(compressionQuality: 0.7); // 0.7 is JPG quality
                userObject.setValue(imageData, forKeyPath: CoreDataManager.userEntityKey_ImageData)
            }
            if let notesUser = userp as? NotesUser {
                userObject.setValue(notesUser.notes, forKeyPath: CoreDataManager.userEntityKey_Notes)
            }
        }// end for

        NSLog("%@ - inserted users to writeContext")
    }

    func update(userp: UserProtocol) {
        let tag = "CoreDataManager.update(user:) - "

        writeContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CoreDataManager.userEntityName)
            let predicate = NSPredicate(format: "id == %d", userp.id)
            fetchRequest.predicate = predicate

            do {
                let fetchedEntities = try self.writeContext.fetch(fetchRequest) as! [UserEntity] //TODO use guard, no force-cast
                if fetchedEntities.count > 1 {
                    NSLog("%@ - ALARM !!! - update() fetched more than 1 entities", tag)
                }

                guard let userEntity = fetchedEntities.first else {
                    NSLog("%@ - update() - fetchedEntities.first is nil", tag)
                    return
                }

                userEntity.login = userp.login
                userEntity.avatarUrl = userp.avatarUrl
                if let image = userp.image {
                    let imageData = image.jpegData(compressionQuality: 0.7); // 0.7 is JPG quality
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
                    NSLog("%@ switch userp default case run !!", tag)
                }
                NSLog("%@ Updated userEntity", tag)
            } catch let error as NSError {
                NSLog("%@ Failed. Error: \(error)", tag)
                NSLog("error.userInfo = %@", error.userInfo)
            }
        }
    }

    func fetchAllUsers() -> [UserProtocol]? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntity")
        let sortById = NSSortDescriptor(key: CoreDataManager.userEntityKey_Id, ascending: true)
        fetchRequest.sortDescriptors = [sortById]

        do {
            let userEntities = try readContext.fetch(fetchRequest)
            if let userEntities = userEntities as? [UserEntity] {
                print("fetchAll - cast to UserEntities successful")
            } else {
                print("fetchAll - cast to UserEntities failed")
            }

            var users = [UserProtocol]()
            var i = 0 // for inverted users
            for userEntity in userEntities {
                let id = userEntity.value(forKey: "id") as? Int
                let login = userEntity.value(forKey: "login") as? String
                let avatarUrl = userEntity.value(forKey: "avatarUrl") as? String
                let imageData = userEntity.value(forKey: "imageData") as? Data
                let notes = userEntity.value(forKey: "notes") as? String

                if let id = id, let login = login, let avatarUrl = avatarUrl {
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
}
