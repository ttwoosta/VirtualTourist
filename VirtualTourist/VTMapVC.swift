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

class VTMapVC: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        // retrieve region setting from userDefault
        if let region = NSUserDefaults.standardUserDefaults().defaultRegion() {
            mapView.region = region
        }
        
        // setup fetched result controller
        self.frc.delegate = self
        self.frc.performFetch(nil)
        
        let fetchRequest = NSFetchRequest(entityName: VTDataManager.EntityNames.Pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(value: true)
        
        let count = self.sharedContext?.countForFetchRequest(fetchRequest, error: nil)
        println("Object count: \(count)")
        
        println("Fetched object: \(self.frc.fetchedObjects!.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                anno.indexPath = newIndexPath
                mapView.addAnnotation(anno)
            case .Update:
                if let anno = annotationForCoordinate(pin.coordinate) {
                    // update location
                    anno.coordinate = pin.coordinate
                    anno.indexPath = newIndexPath
                }
            case .Delete:
                if let anno = annotationForCoordinate(pin.coordinate) {
                    mapView.removeAnnotation(anno)
                }
            default:
                println(pin)
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        
    }


    //////////////////////////////////
    //  MARK: Long press action
    /////////////////////////////////
    
    @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
        // get touch point and convert to mapView coordinate
        let touchPoint = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        // if annotation at coordinate does not exist
        // **for some reason long press action fire twice
        // **the purple of this is prevent duplicated insert pins
        if annotationForCoordinate(coordinate) == nil {
            let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Pin, inManagedObjectContext: self.sharedContext!)
            let pin = VTPin(entity: entity!, insertIntoManagedObjectContext: self.sharedContext!)
            pin.coordinate = coordinate
        }
    }
    
    //////////////////////////////////
    //  MARK: Query annotation
    /////////////////////////////////
    
    func annotationForCoordinate(coord: CLLocationCoordinate2D) -> VTPointAnnotation! {
        for anno in mapView.annotations as! [VTPointAnnotation] {
            if anno.coordinate.latitude == coord.latitude && anno.coordinate.longitude == coord.longitude {
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
            if annotationForCoordinate(pin.coordinate) == nil {
                var anno = pin.pointAnnotation()
                anno.title = "Location"
                anno.indexPath = self.frc.indexPathForObject(pin)
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
            
            //let btn = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            //pinView.rightCalloutAccessoryView = btn
        }
        else {
            pinView!.annotation = annotation
            pinView.pinColor = .Red
        }
        
        // retrieve pin object associates annotation
        if let anno = annotation as? VTPointAnnotation {
            if let pin = self.frc.objectAtIndexPath(anno.indexPath) as? VTPin {
                
                // set pin color according to inserted state
                // green for new insert and red for saved objects
                pinView.pinColor = pin.inserted ? .Green : .Red
            }
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let anno = view.annotation as? VTPointAnnotation {
            if let selectedPin = self.frc.objectAtIndexPath(anno.indexPath) as? VTPin {
                if let vc = storyboard?.instantiateViewControllerWithIdentifier("PinDetailVC") as? VTPinDetailVC {
                    vc.pinID = selectedPin.objectID
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
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

}

