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
    static let shared = CoreDataManager()
    private init() {}

    func insert(users: [User]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        for user in users {
            let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: managedContext)!
            let userObject = NSManagedObject(entity: entity, insertInto: managedContext)

            userObject.setValue(user.id, forKeyPath: "id")
            userObject.setValue(user.login, forKeyPath: "login")
            userObject.setValue(user.avatarUrl, forKeyPath: "avatarUrl")
            if let image = user.image {
                let imageData = UIImageJPEGRepresentation(image, 0.7); // 0.7 is JPG quality
                userObject.setValue(imageData, forKeyPath: "imageData")
            }
            userObject.setValue(user.notes, forKeyPath: "notes")
        }// end for

        do {
            try managedContext.save()
            NSLog("successfully saved users to db")
        } catch let error as NSError {
            NSLog("Error on save users to db. \(error), \(error.userInfo)")
        }
    }

    func update(user: User) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            NSLog("Failed to get app delegate")
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "id == %d", user.id)
        fetchRequest.predicate = predicate

        do {
            let fetchedEntities = try managedContext.fetch(fetchRequest) as! [UserEntity]
            let userEntity = fetchedEntities.first
            userEntity?.login = user.login
            userEntity?.avatarUrl = user.avatarUrl

            if let image = user.image {
                let imageData = UIImageJPEGRepresentation(image, 0.7); // 0.7 is JPG quality
                userEntity?.imageData = imageData
            }

            userEntity?.notes = user.notes
            try managedContext.save()
        } catch let error as NSError {
            NSLog("Could not save. \(error), \(error.userInfo)")
        }
    }

    func fetchAllUsers() -> [User]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntity")

        do {
            let userEntities = try managedContext.fetch(fetchRequest)
            var users = [User]()
            for userEntity in userEntities {
                print(userEntity)
                let id = userEntity.value(forKey: "id") as? Int
                let login = userEntity.value(forKey: "login") as? String
                let avatarUrl = userEntity.value(forKey: "avatarUrl") as? String
                let imageData = userEntity.value(forKey: "imageData") as? Data
                let notes = userEntity.value(forKey: "notes") as? String

                if let id = id, let login = login, let avatarUrl = avatarUrl {
                    var user = User(id: id, login: login, avatarUrl: avatarUrl, notes: notes ?? "")
                    user.image = imageData !=  nil ? UIImage(data: imageData!) : nil
                    users.append(user)
                }
            }
            return users
        } catch let error as NSError {
            NSLog("CoreData - fetchAllUsers error: %@.", error)
            NSLog("CoreData - fetchAllUsers error.userInfo: %@.", error.userInfo)
            return nil
        }
    }
}
