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

class VTPinDetailVC: UIViewController {
    
    // selected pin
    var pinID: NSManagedObjectID!
    
    // retaining search photo task for cancellation
    var searchPhotoTask: NSURLSessionTask!
    
    // outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerImageCollection: UIView!
    @IBOutlet weak var barItemNewCollection: UIBarButtonItem!
    
    // child collection view controller
    var imageCVC: VTImageCVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve selected pin object
        let selectedPin = self.sharedContext?.objectRegisteredForID(pinID) as! VTPin
        
        // add pin's annotation
        let anno = selectedPin.pointAnnotation()
        mapView.addAnnotation(anno)
        
        // zoom map
        let span = MKCoordinateSpanMake(1.5, 2.5)
        let region = MKCoordinateRegionMake(anno.coordinate, span)
        mapView.region = region
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // retrieve selected pin object
        let selectedPin = self.sharedContext?.objectRegisteredForID(pinID) as! VTPin
        
        if selectedPin.photos.count > 0 {
            return
        }
        
        let coord = selectedPin.coordinate
        searchPhotoTask = FlickrClient.searchPhotosByCoodinate(coord) { result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let photoDicts = result as? [[String: AnyObject]] {
                    
                    let context = self.sharedContext!
                    let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Photo, inManagedObjectContext: context)!
                    
                    for dict in photoDicts {
                        var photo = VTPhoto(entity: entity, insertIntoManagedObjectContext: context)
                        photo.decodeWith(dict)
                        photo.pin = selectedPin
                    }
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
            }
        }
    }
    
    //////////////////////////////////
    // MARK: Core data stack
    /////////////////////////////////
    
    lazy var sharedContext: NSManagedObjectContext? = {
        return VTDataManager.sharedInstance().managedObjectContext
    }()
    
    //////////////////////////////////
    // MARK: New collection action
    /////////////////////////////////
    
    @IBAction func newCollectionAction(sender: AnyObject) {
        var error: NSError? = nil
        self.sharedContext?.save(&error)
        println(error)
    }
    
}
