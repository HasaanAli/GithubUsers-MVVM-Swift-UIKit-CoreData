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
    static let sharedInstance = CoreDataManager()
    private init() {}

    var sharedUIApplicationDelegate: UIApplicationDelegate? {
        return UIApplication.shared.delegate
    }

    /// Can be used from UI thread.
    func insert(users: [UserProtocol]) {
        guard let appDelegate = sharedUIApplicationDelegate as? AppDelegate else {
            NSLog("")
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        for userp in users {
            let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: managedContext)!
            let userObject = NSManagedObject(entity: entity, insertInto: managedContext)

            userObject.setValue(userp.id, forKeyPath: "id")
            userObject.setValue(userp.login, forKeyPath: "login")
            userObject.setValue(userp.avatarUrl, forKeyPath: "avatarUrl")
            if let image = userp.image {
                let imageData = image.jpegData(compressionQuality: 0.7); // 0.7 is JPG quality
                userObject.setValue(imageData, forKeyPath: "imageData")
            }
            if let notesUser = userp as? NotesUser {
                userObject.setValue(notesUser.notes, forKeyPath: "notes")
            }
        }// end for

        do {
            try managedContext.save()
            NSLog("successfully saved users to db")
        } catch let error as NSError {
            NSLog("Error on save users to db. \(error), \(error.userInfo)")
        }
    }

    func update(userp: UserProtocol) {
        let tag = "CoreDataManager.update(user:) -"
        guard let appDelegate = sharedUIApplicationDelegate as? AppDelegate else {
            NSLog("CoreDataManager.update(user:) - Failed to get app delegate")
            return
        }

        DispatchQueue.global(qos: .background).async {
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntity")
            let predicate = NSPredicate(format: "id == %d", userp.id)
            fetchRequest.predicate = predicate

            do {
                let fetchedEntities = try managedContext.fetch(fetchRequest) as! [UserEntity] //TODO use guard, no force-cast
                let userEntity = fetchedEntities.first
                userEntity?.login = userp.login
                userEntity?.avatarUrl = userp.avatarUrl
                if let image = userp.image {
                    let imageData = image.jpegData(compressionQuality: 0.7); // 0.7 is JPG quality
                    userEntity?.imageData = imageData
                }

                switch userp {
                case is User:
                    userEntity?.notes = nil
                case let invertedUser as InvertedUser:
                    userEntity?.notes = invertedUser.notes
                case let notesUser as NotesUser:
                    userEntity?.notes = notesUser.notes.isEmpty ? nil :  notesUser.notes
                default:
                    NSLog("%@ switch userp default case run !!", tag)
                }

                try managedContext.save()
                NSLog("%@ Success", tag)
            } catch let error as NSError {
                NSLog("%@ Failed. Error: \(error)", tag)
                NSLog("error.userInfo = %@", error.userInfo)
            }
        }
    }

    func fetchAllUsers() -> [UserProtocol]? {
        guard let appDelegate = sharedUIApplicationDelegate as? AppDelegate else {
            NSLog("CoreDataManager.fetchAllUsers() - Failed to get app delegate")
            return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntity")

        do {
            let userEntities = try managedContext.fetch(fetchRequest)
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
