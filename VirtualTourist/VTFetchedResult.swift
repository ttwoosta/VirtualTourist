//
//  VTFetchedResult.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/21/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import CoreData

class VTFetchedResult {
    
    var changeType: NSFetchedResultsChangeType
    weak var changedObject: AnyObject!
    weak var indexPath: NSIndexPath? = nil
    weak var newIndexPath: NSIndexPath? = nil
    
    init(didChangeObject anObject: AnyObject, atIndexPath ip: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath nip: NSIndexPath?) {
        changedObject = anObject
        changeType = type
        indexPath = ip
        newIndexPath = nip
    }
    
}