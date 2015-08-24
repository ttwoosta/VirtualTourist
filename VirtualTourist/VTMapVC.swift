//
//  VTMapVC.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import MapKit
import CoreData

enum VTMapVCState {
    case Default, Editing
}

class VTMapVC: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cntMapUpDown: NSLayoutConstraint!
    
    // new inserted pin
    // will be nil when user release figure
    weak var dragingPin: VTPin!
    
    //////////////////////////////////
    // MARK: Override methods
    /////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        // retrieve region setting from userDefault
        if let region = NSUserDefaults.standardUserDefaults().defaultRegion() {
            mapView.region = region
        }
        
        // setup fetched result controller
        self.frc.delegate = self
        self.frc.performFetch(nil)
        
        self.state = .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////////
    // MARK: State
    /////////////////////////////////
    
    var state: VTMapVCState = .Default {
        didSet {
            switch state {
            case .Default:
                cntMapUpDown.constant = 0
                let barItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editBarItemAction:")
                navigationItem.rightBarButtonItem = barItem
                
            case .Editing:
                cntMapUpDown.constant = 70
                let barItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneBarItemAction:")
                navigationItem.rightBarButtonItem = barItem
            }
        }
    }
    
    func editBarItemAction(sender: UIBarButtonItem) {
        UIView.animateWithDuration(0.25) {
            self.state = .Editing
            self.view.layoutIfNeeded()
        }
    }
    
    func doneBarItemAction(sender: UIBarButtonItem) {
        UIView.animateWithDuration(0.25) {
            self.state = .Default
            self.view.layoutIfNeeded()
        }
    }
    
    //////////////////////////////////
    // MARK: NSFetchedResultsControllerDelegate
    /////////////////////////////////
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if let pin = anObject as? VTPin {
            switch type {
            case .Insert:
                var anno = pin.pointAnnotation()
                anno.title = "Location"
                mapView.addAnnotation(anno)
            case .Update:
                if let anno = annotationForID(pin.id) {
                    // update location
                    anno.coordinate = pin.coordinate
                    anno.id = pin.id
                }
            case .Delete:
                if let anno = annotationForID(pin.id) {
                    mapView.removeAnnotation(anno)
                }
            case .Move:
                println("move item at: \(newIndexPath)")
            }
        }
    }

    //////////////////////////////////
    //  MARK: Long press action
    /////////////////////////////////
    
    @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
        // only insert one pin for each long press touch
        if sender.state == .Began {
            // get touch point and convert to mapView coordinate
            let touchPoint = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            // initialize pin at touch location
            let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Pin, inManagedObjectContext: self.sharedContext!)
            let pin = VTPin(entity: entity!, insertIntoManagedObjectContext: self.sharedContext!)
            pin.coordinate = coordinate
            
            // set selected pin
            dragingPin = pin
        }
        else if sender.state == .Changed {
            // get touch point and convert to mapView coordinate
            let touchPoint = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            // move pin to new location
            dragingPin.coordinate = coordinate
        }
        else {
            // save dropped pin
            VTDataManager.sharedInstance().saveContext()
            
            // search photos for drop pin
            VTDataManager.searchPhotosFor(dragingPin, page: 1) { fetchedResult, error  in
                
                switch fetchedResult {
                case .Succeed:
                    VTDataManager.sharedInstance().saveContext()
                case .NoPhoto:
                    println("No photos")
                case .ErrorOccurs:
                    println(error)
                }
            }
            
            dragingPin = nil
        }
    }
    
    //////////////////////////////////
    //  MARK: Query annotation
    /////////////////////////////////
    
    func annotationForID(id: String) -> VTPointAnnotation! {
        for anno in mapView.annotations as! [VTPointAnnotation] {
            if anno.id == id {
                return anno
            }
        }
        return nil
    }
    
    //////////////////////////////////
    //  MARK: MKMapViewDelegate
    /////////////////////////////////
    
    func mapViewWillStartLoadingMap(mapView: MKMapView!) {
        
        for pin in self.frc.fetchedObjects as! [VTPin] {
            if annotationForID(pin.id) == nil {
                var anno = pin.pointAnnotation()
                anno.title = "Location"
                mapView.addAnnotation(anno)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDefaultRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        var pinView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)!
            pinView.canShowCallout = false
            pinView.animatesDrop = true
            pinView.pinColor = .Red
        }
        else {
            pinView.annotation = annotation
            pinView.pinColor = .Red
        }
        
        // retrieve pin object associates annotation
        if let anno = annotation as? VTPointAnnotation {
            if let pin = pinForUniqueID(anno.id) {
                
                // set pin color according to inserted state
                // green for new insert and red for saved objects
                pinView.pinColor = pin.inserted ? .Green : .Red
            }
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        if let anno = view.annotation as? VTPointAnnotation {
            if let selectedPin = pinForUniqueID(anno.id) {
                if self.state == .Editing {
                    self.sharedContext?.deleteObject(selectedPin)
                    VTDataManager.sharedInstance().saveContext()
                }
                else {
                    if let vc = storyboard?.instantiateViewControllerWithIdentifier("PinDetailVC") as? VTPinDetailVC {
                        vc.pinID = selectedPin.objectID
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
    }
    
    //////////////////////////////////
    // MARK: Core data stack
    /////////////////////////////////
    
    lazy var sharedContext: NSManagedObjectContext? = {
        return VTDataManager.sharedInstance().managedObjectContext
    }()
    
    lazy var frc: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: VTDataManager.EntityNames.Pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(value: true)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext!, sectionNameKeyPath: nil, cacheName: nil)
        return frc
        
    }()
    
    func pinForUniqueID(id: String) -> VTPin? {
        for pin in self.frc.fetchedObjects as! [VTPin] {
            if pin.id == id {
                return pin
            }
        }
        return nil
    }

}

