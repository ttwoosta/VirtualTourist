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

    weak var pinDetailVC: VTPinDetailVC!
    var pinID: NSManagedObjectID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let user select multiple items
        collectionView?.allowsMultipleSelection = true
        
        // setup fetched result controller
        self.frc.delegate = self
        self.frc.performFetch(nil)
    }
    
    deinit {
        VTImageFetcher.cancelAllTasks()
        println("Deinit \(self)")
    }
    
    //////////////////////////////////
    // MARK: NSFetchedResultsControllerDelegate
    /////////////////////////////////
    
    func controllerWillChangeContent(controller: VTFetchedResultsController) {
        //println("frc will change content")
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
        
        // TODO: get image from cache
        if (photoObject.image != nil) {
            cell.imageView.image = photoObject.image
            return
        }
        
        // disable new collection button
                
        // start spin and clear previous image
        cell.spinner.startAnimating()
        cell.imageView.image = nil
        
        // set cell identifier
        let identifier = photoObject.id
        cell.identifier = identifier
        
        // create url request
        let URLRequest = NSURLRequest(URL: photoObject.imageURL)
        
        // disable new collection barItem
        pinDetailVC.bottomBar.style = .Fetching
        
        // download image for photo
        let task = VTImageFetcher.fetchImageForURL(photoObject.imageURL, getImageHandler: {image, imageData, error in
            if image != nil {
                if cell.identifier == identifier {
                    cell.imageView.image = image
                    cell.spinner.stopAnimating()
                    
                    // store image to cache
                    photoObject.setImage(image, imageData: imageData)
                }
            }
            else {
                println(error)
            }
        },
        completionHandler: {[weak self] in
            self?.pinDetailVC.bottomBar.style = .NewCollection
        })
        
        // set task for cancellation
        cell.taskToCancelIfReused = task
    }
    
    //////////////////////////////////
    // MARK: CollectionView DataSource
    /////////////////////////////////
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    // MARK: CollectionView Delegate
    /////////////////////////////////
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        pinDetailVC.bottomBar.style = .DeletePhotos
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.indexPathsForSelectedItems().count == 0 {
            pinDetailVC.bottomBar.style = .NewCollection
        }
    }
    
    //////////////////////////////////
    // MARK: Core data stack
    /////////////////////////////////
    
    lazy var frc: VTFetchedResultsController = {
        
        let context = VTDataManager.sharedInstance().managedObjectContext!
        
        // retrieve selected pin object
        let selectedPin = context.objectRegisteredForID(self.pinID) as! VTPin
        
        let fetchRequest = NSFetchRequest(entityName: VTDataManager.EntityNames.Photo)
        
        // TODO: Debug predicate
        fetchRequest.predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        
        let frc = VTFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
        
    }()
    
}
