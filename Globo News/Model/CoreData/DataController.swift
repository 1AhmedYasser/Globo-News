//
//  DataController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import Foundation
import CoreData

// a class that encapsulates the core data stack setup
class DataController {
    
    // Create and initialize the persisitant container
    let persistentContainer: NSPersistentContainer
    
    // A Computed property that returns the persistent Container view context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Initiate the persistent container with a given model name
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // Configure Contexts
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    // Use the persistent Container to load the persistent store
    func loadPersistentStore(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        }
    }
    
    // Create a shared Model
    static let shared = DataController(modelName: "GloboNewsModel")
}
