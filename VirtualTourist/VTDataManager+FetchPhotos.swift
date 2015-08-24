//
//  VTDataManager+FetchPhotos.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/23/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import CoreData
import UIKit

public enum VTDataManagerFetchedResult: Int {
    case Succeed, NoPhoto, ErrorOccurs
}

extension VTDataManager {
    
    
    public class func searchPhotosFor(pin: VTPin, page: Int, completionHandler: (result: VTDataManagerFetchedResult, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let coord = pin.coordinate
        
        let task = FlickrClient.searchPhotosByCoodinate(coord, page: page) { result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    if let photoDicts = result as? [[String: AnyObject]] {
                        if photoDicts.count > 0 {
                            // save current fickr page
                            pin.flikrSearchPage = page
                            
                            // get shared managed object context
                            let context = self.sharedInstance().managedObjectContext!
                            
                            // delete existing photos
                            for photo in pin.photos {
                                context.deleteObject(photo)
                            }
                            
                            // initializes new photos
                            let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Photo, inManagedObjectContext: context)!
                            for dict in photoDicts {
                                var photo = VTPhoto(entity: entity, insertIntoManagedObjectContext: context)
                                photo.decodeWith(dict)
                                photo.pin = pin
                            }
                            
                            // save context
                            VTDataManager.sharedInstance().saveContext()
                            completionHandler(result: .Succeed, error: nil)
                            return
                        }
                    }
                    
                    // TODO: No photo found
                    completionHandler(result: .NoPhoto, error: nil)
                }
                else {
                    // TODO: Error occurs
                    completionHandler(result: .ErrorOccurs, error: error)
                }
            }
        }
        
        return task
    }
    
}
