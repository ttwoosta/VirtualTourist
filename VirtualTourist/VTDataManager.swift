//
//  VTDataManager.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import CoreData


public class VTDataManager: CoreDataStackManager {
    
    public class func sharedInstance() -> CoreDataStackManager {
        struct Singleton {
            static var sharedInstance = CoreDataStackManager(managedObjectModelName: "VirtualTourist")
        }
        return Singleton.sharedInstance
    }
    
    
    public struct EntityNames {
        public static let Pin: String = "VTPin"
        public static let Photo: String = "VTPhoto"
    }
    
}
