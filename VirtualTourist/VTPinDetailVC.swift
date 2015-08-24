//
//  VTPinDetailVC.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData
import MapKit


enum VTPinDetailVCState {
    case Default, Loading, NoPhoto, ErrorOccurs
}

class VTPinDetailVC: UIViewController {
    
    var state: VTPinDetailVCState = .Default {
        didSet {
            switch state {
            case .Default:
                containerImageCollection.alpha = 1
                spinner.stopAnimating()
                lblLoading.text = ""
                lblLoading.alpha = 0
                self.bottomBar.style = .NewCollection
            case .Loading:
                containerImageCollection.alpha = 0
                spinner.startAnimating()
                lblLoading.text = "Loading..."
                lblLoading.alpha = 1
                self.bottomBar.style = .Fetching
            case .NoPhoto:
                containerImageCollection.alpha = 0
                spinner.stopAnimating()
                lblLoading.text = "No photo for this location."
                lblLoading.alpha = 1
                self.bottomBar.style = .TryAgain
            case .ErrorOccurs:
                containerImageCollection.alpha = 0
                spinner.stopAnimating()
                lblLoading.text = "An error occurs. Tap to retry."
                lblLoading.alpha = 1
                self.bottomBar.style = .TryAgain
            }
        }
    }
    
    // selected pin
    var pinID: NSManagedObjectID!
    
    // retaining search photo task for cancellation
    weak var searchPhotoTask: NSURLSessionTask? = nil
    
    // outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerImageCollection: UIView!
    @IBOutlet weak var bottomBar: VTBottomBar!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var lblLoading: UILabel!

    // child collection view controller
    var imageCVC: VTImageCVC!
    
    //////////////////////////////////
    // MARK: Override methods
    /////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add pin's annotation
        let anno = self.selectedPin.pointAnnotation()
        mapView.addAnnotation(anno)
        
        
        // retrieve region setting from userDefault
        if let region = NSUserDefaults.standardUserDefaults().defaultRegion() {
            let newRegion = MKCoordinateRegionMake(anno.coordinate, region.span)
            mapView.region = newRegion
        }
        
        // setup bottom bar items actions
        bottomBar.newCollectionItem.target = self
        bottomBar.newCollectionItem.action = Selector("newCollectionAction:")
        bottomBar.removePhotoItem.target = self
        bottomBar.removePhotoItem.action = Selector("deletePhotosAction:")
        bottomBar.cancelItem.target = self
        bottomBar.cancelItem.action = Selector("cancelLoadingAction:")
        bottomBar.tryAgainItem.target = self
        bottomBar.tryAgainItem.action = Selector("tryAgainAction:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // selectedPin's photos collection already fetched
        if self.selectedPin.photos.count > 0 {
            self.state = .Default
        }
        else {
            searchPhotosSelectedPin()
        }
    }
    
    deinit {
        searchPhotoTask?.cancel()
        println("Deinit \(self)")
    }
    
    //////////////////////////////////
    // MARK: Toolbar's action
    /////////////////////////////////
    
    func newCollectionAction(sender: AnyObject) {
        // retrieve selected pin object
        let selectedPin = self.selectedPin
        
        // fetch photos
        let coord = selectedPin.coordinate
        let page = selectedPin.flikrSearchNextPageValue
        
        // update ui
        self.state = .Loading
        
        // search photos for selected pin
        searchPhotoTask = VTDataManager.searchPhotosFor(selectedPin, page: page) {[weak self] fetchResult, error  in
            
            switch fetchResult {
            case .Succeed:
                // save current search page
                selectedPin.flikrSearchPage = page
                self?.state = .Default
            case .NoPhoto:
                self?.state = .NoPhoto
            case .ErrorOccurs:
                self?.state = .ErrorOccurs
                if let desc: String = error?.localizedDescription {
                    self?.lblLoading.text = desc
                }
            }
        }
    }
    
    func deletePhotosAction(sender: AnyObject) {
        let context = self.sharedContext!
        let frc = imageCVC.frc
        for indexPath in imageCVC.collectionView?.indexPathsForSelectedItems() as! [NSIndexPath] {
            if let photo = frc.objectAtIndexPath(indexPath) as? VTPhoto {
                context.deleteObject(photo)
            }
        }
        VTDataManager.sharedInstance().saveContext()
        
        // show new collection bar item
        self.bottomBar.style = .NewCollection
    }
    
    func cancelLoadingAction(sender: AnyObject) {
        searchPhotoTask?.cancel()
        VTImageFetcher.cancelAllTasks()
    }
    
    func tryAgainAction(sender: AnyObject) {
        searchPhotosSelectedPin()
    }
    
    //////////////////////////////////
    // MARK: Search photos
    /////////////////////////////////
    
    func searchPhotosSelectedPin() {
        
        // retrieve selected pin object
        let selectedPin = self.selectedPin
        
        // fetch photos
        let coord = selectedPin.coordinate
        let page = selectedPin.flikrSearchPage
        
        // update ui
        self.state = .Loading
        
        // search photos for selected pin
        searchPhotoTask = VTDataManager.searchPhotosFor(selectedPin, page: page) {[weak self] fetchedResult, error  in
            
            switch fetchedResult {
            case .Succeed:
                self?.state = .Default
            case .NoPhoto:
                self?.state = .NoPhoto
            case .ErrorOccurs:
                self?.state = .ErrorOccurs
                if let desc: String = error?.localizedDescription {
                    self?.lblLoading.text = desc
                }
            }
            
        }
    }
    
    //////////////////////////////////
    // MARK: Segue
    /////////////////////////////////
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "imageCVC" {
            if let vc = segue.destinationViewController as? VTImageCVC {
                imageCVC = vc
                imageCVC.pinID = pinID
                
                vc.pinDetailVC = self
            }
        }
    }
    
    //////////////////////////////////
    // MARK: Core data stack
    /////////////////////////////////
    
    lazy var sharedContext: NSManagedObjectContext? = {
        return VTDataManager.sharedInstance().managedObjectContext
    }()
    
    var selectedPin: VTPin {
        // retrieve selected pin object
        var error: NSError? = nil
        let selectedPin: VTPin? = self.sharedContext?.objectRegisteredForID(pinID) as? VTPin
        assert(selectedPin != nil, "Selected pin couldn't be found")
        assert(error == nil, "error")
        
        return selectedPin!
    }
}
