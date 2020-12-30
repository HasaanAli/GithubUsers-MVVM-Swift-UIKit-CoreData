//
//  AppDelegate.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static let coreDataManager = CoreDataManager()
    static let githubUsersClient = GithubUsersClient()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        AppDelegate.coreDataManager.saveChangesIfAny(synchronously: true)
    }
}

