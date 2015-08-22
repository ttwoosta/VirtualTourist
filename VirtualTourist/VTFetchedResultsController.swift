//
//  VTFetchedResultsController.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/21/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//


import CoreData

protocol VTFetchedResultsControllerDelegate: NSObjectProtocol {
    func controllerWillChangeContent(controller: VTFetchedResultsController)
    func controllerDidChangeContent(controller: VTFetchedResultsController, updateResults:[VTFetchedResult])
}

class VTFetchedResultsController: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var delegate: VTFetchedResultsControllerDelegate?
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var updateResults: [VTFetchedResult]!
        
    //////////////////////////////////
    // MARK: Init
    /////////////////////////////////

    var frc: NSFetchedResultsController!
    
    init(fetchRequest request: NSFetchRequest, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath secKeyPath: String?, cacheName name: String?) {
        super.init()
        
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: secKeyPath, cacheName: name)
        frc.delegate = self
    }
    
    //////////////////////////////////
    // MARK: performFetch
    /////////////////////////////////
    
    func performFetch(error: NSErrorPointer) -> Bool {
        return self.frc.performFetch(error)
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return self.frc.objectAtIndexPath(indexPath)
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        if let currentSection = self.frc.sections?[section] as? NSFetchedResultsSectionInfo {
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    //////////////////////////////////
    // MARK: NSFetchedResultsControllerDelegate
    /////////////////////////////////
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        updateResults = [VTFetchedResult]()
        delegate?.controllerWillChangeContent(self)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        delegate?.controllerDidChangeContent(self, updateResults: updateResults)
        updateResults = nil
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let result = VTFetchedResult(didChangeObject: anObject,
            atIndexPath: indexPath,
            forChangeType: type,
            newIndexPath: newIndexPath)
        updateResults.append(result)
    }
    
}


/*

UDACITY: Jason (ColorCollection project)

###The Color Collection

The color collection app demonstrates two techniques that will be importanta for the Virtual Tourist app.

- Using UICollectionView with NSFetchedResultsController
- Maintaining a set of "selected" cells

Take a minute to run the app. It adds cells with randomly generated colors when the `+` button is tapped. When users touch the color cells they are "selected" to be delted. Tapping the "Remove Selected Colors" button deletes the cells that have been selected.

##Collections and Fetched Results Controllers.

The `NSFetchedResultsControllerDelegate` methods are designed to work smoothly with UITableViews. They are slightly more complicated to use with Collection Views. The difference is a method on collections views named `performBatchUpdates`.

This method accepts a closure that should make a complete set of changes. To make this work smoothly with the fetched results controller delegate, we need to store a batch of changes in our view controller, then execute them all inside this closure.

In this example code we accomplish this by keeping three arrays of index paths:

- insertedIndexPaths
- deletedIndexPaths
- updatedIndexPaths

Whenever changes are made to the Color objects in Core Data three steps will take place:

1. The fetched results controller will invoke `controllerWillChangeContent` on the view controller. We will respond by creating three empty arrays.
2. The fetched results controller will invoke `controller(: didChangeObject:atIndexPath:forChangeType:newIndexPath)`. That represents a change, and we will insert the index path into the appropriate array.
3. The fetched results controller will invoke `controllerDidChangeContent` on the view controller. We respond by performing the changes saved in the arrays inside the `performBatchUpdates` method.

Read through these steps in the ColorsViewController and see if that prompts disucssion for the forums.

##Maintaining a set of selected cells

The view controller allows the user to tap color cells to toggle them between being selected and unselected. Selected cells can be deleted using the "Remove Selected Colors" button. The effect is acheived by keeping an array of index paths named `selectedIndexes`. Whenever a cell is tapped its index path is added to this array (or removed, if it was already present). This toggles the "selected" state for the cell.

The array is used in `configureCell` to show some visual indication that the cell is selected. In this app the alpha is set to 0.05 on selected cells. They are "grayed out" so to speak. But they could have checkmarks, or borders, or any number of other visual indications.
*/