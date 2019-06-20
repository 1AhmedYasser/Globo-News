//
//  AppDelegate.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/8/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Loads the shared persistent store and check for data in order to open the appropriate controller
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Load the shared persistent store
        DataController.shared.loadPersistentStore()
        
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        fetchRequest.sortDescriptors = []
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            if result.count > 0 {
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                self.window?.rootViewController = initialViewController
            } else {
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "CountrySelectionController") as! CountrySelectionViewController
                self.window?.rootViewController = initialViewController
            }
        }
        return true
    }
    // Save the view context when the app is in the background
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    // Save the view context when the app terminates or crashes
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    // MARK: Helper methods
    // A helper method that saves changes to the persistent store
    func saveViewContext() {
        try? DataController.shared.viewContext.save()
    }
}

