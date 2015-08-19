//
//  CoreDataStackManager.swift
//  FavoriteActors
//
//  Created by Tu Tong on 8/15/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataStackManager {

    var objectModelName: String!

    init(managedObjectModelName: String) {
        objectModelName = managedObjectModelName
    }
    
    lazy var dataStoreURL: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls.last as! NSURL
        let dataStoreURL = docURL.URLByAppendingPathComponent("\(self.objectModelName).sqlite")
        return dataStoreURL
    }()
    
    // The managed object model for the application. This property is not optional. 
    // It is a fatal error for the application not to be able to find and load its model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.objectModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    // The persistent store coordinator for the application. 
    // This implementation creates and return a coordinator,
    // having added the store for the application to it. 
    // This property is optional since there are legitimate error conditions
    // that could cause the creation of the store to fail.
    lazy var persistenceStoreCoordinator: NSPersistentStoreCoordinator? = {
        // create the coordinator
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        var apError: NSError? = nil
        if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.dataStoreURL, options: nil, error: &apError) == nil {
            println(apError)
            
            // remove data store
            let fileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtURL(self.dataStoreURL, error: nil)
            
            // re-initialize persistence store coordinator
            return self.persistenceStoreCoordinator
        }
        
        return coordinator
    }()
    
    // Returns the managed object context for the application 
    // (which is already bound to the persistent store coordinator for the application.) 
    // This property is optional since there are legitimate error conditions 
    // that could cause the creation of the context to fail.
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let psc = self.persistenceStoreCoordinator
        var context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        return context
    }()
    
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                
                // remove data store
                let fileManager = NSFileManager.defaultManager()
                fileManager.removeItemAtURL(self.dataStoreURL, error: nil)
                
                // save changes
                saveContext()
            }
        }
    }
    
}