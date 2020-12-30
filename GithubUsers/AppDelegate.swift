//
//  AppDelegate.swift
//  GithubUsers
//
//  Created by Hasaan Ali on 12/18/20.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static var coreDataManager: CoreDataManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if getenv("isTesting") != nil {
            NSLog("isTesting launch argument passed, not instantiating vc")
            return true
        }

        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateInitialViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        AppDelegate.coreDataManager?.saveChangesIfAny(synchronously: true)
    }
}
