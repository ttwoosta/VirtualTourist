//
//  VTImageCVC.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class VTImageCVC: UICollectionViewController, VTFetchedResultsControllerDelegate {

    var pinID: NSManagedObjectID!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup fetched result controller
        self.frc.delegate = self
        self.frc.performFetch(nil)
    }
    
    //////////////////////////////////
    // MARK: NSFetchedResultsControllerDelegate
    /////////////////////////////////
    
    func controllerWillChangeContent(controller: VTFetchedResultsController) {
        println("frc will change content")
    }
    
    func controllerDidChangeContent(controller: VTFetchedResultsController, updateResults: [VTFetchedResult]) {
        
        collectionView!.performBatchUpdates({[weak self] in
            
            for result in updateResults {
                switch result.changeType {
                case .Insert:
                    self?.collectionView?.insertItemsAtIndexPaths([result.newIndexPath!])
                case .Update:
                    let indexPath = result.newIndexPath!
                    if let cell = self?.collectionView?.cellForItemAtIndexPath(indexPath) as? VTImageCell {
                        if let photo = controller.objectAtIndexPath(indexPath) as? VTPhoto {
                            self?.configCell(cell, photoObject: photo)
                        }
                    }
                case .Delete:
                    self?.collectionView?.deleteItemsAtIndexPaths([result.indexPath!])
                case .Move:
                    println(result.changedObject)
                }
            }
        }, completion: nil)

    }
    
    func configCell(cell: VTImageCell, photoObject: VTPhoto) {
        
        // start spin and clear previous image
        cell.spinner.startAnimating()
        cell.imageView.image = nil
        
        // set cell identifier
        let identifier = photoObject.id
        cell.identifier = identifier
        
        // create url request
        let URLRequest = NSURLRequest(URL: photoObject.imageURL)
        
        // get image from photo object
        if (photoObject.image != nil) {
            cell.imageView.image = photoObject.image
            return
        }
        
        // download image for photo
        let task = VTImageFetcher.fetchImageForURL(photoObject.imageURL, getImageHandler: {image, error in
            if image != nil {
                if cell.identifier == identifier {
                    photoObject.image = image
                    cell.imageView.image = image
                    cell.spinner.stopAnimating()
                }
            }
            else {
                println(error)
            }
        },
        completionHandler: {
            
        })
        
        // set task for cancellation
        cell.taskToCancelIfReused = task
    }
    
    //////////////////////////////////
    // MARK: CollectionView Delegate
    /////////////////////////////////
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("Number of items \(self.frc.numberOfItemsInSection(section))")
        return self.frc.numberOfItemsInSection(section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseID = "cell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! VTImageCell
        
        let photo = self.frc.objectAtIndexPath(indexPath) as! VTPhoto
        
        configCell(cell, photoObject: photo)
        
        return cell
    }
    
    //////////////////////////////////
    // MARK: Core data stack
    /////////////////////////////////
    
    lazy var sharedContext: NSManagedObjectContext? = {
        return VTDataManager.sharedInstance().managedObjectContext
    }()
    
    lazy var frc: VTFetchedResultsController = {
        
        // retrieve selected pin object
        let selectedPin = self.sharedContext?.objectRegisteredForID(self.pinID) as! VTPin
        
        let fetchRequest = NSFetchRequest(entityName: VTDataManager.EntityNames.Photo)
        
        // TODO: Debug predicate
        fetchRequest.predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        
        let frc = VTFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext!, sectionNameKeyPath: nil, cacheName: nil)
        return frc
        
    }()
    
}
