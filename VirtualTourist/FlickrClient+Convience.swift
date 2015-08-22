//
//  FlickrClient+Convience.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension FlickrClient {
    
    public class func createBoundingBoxString(latitude: Double, longitude: Double) -> String {

        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BoundingBox.HalfWidth, Longitude.Min)
        let bottom_left_lat = max(latitude - BoundingBox.HalfHeight, Latitude.Min)
        let top_right_lon = min(longitude + BoundingBox.HalfHeight, Longitude.Max)
        let top_right_lat = min(latitude + BoundingBox.HalfHeight, Latitude.Max)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    public class func searchPhotosByCoodinate(coordinate: CLLocationCoordinate2D, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let bbox = createBoundingBoxString(coordinate.latitude, longitude: coordinate.longitude)
        
        let parameters = [ ParameterKeys.BoundingBox: bbox,
            ParameterKeys.Extras: Constants.EXTRAS,
            ParameterKeys.Method: Constants.METHOD_NAME,
            ParameterKeys.SafeSearch: Constants.SAFE_SEARCH,
            ParameterKeys.Format: Constants.DATA_FORMAT,
            ParameterKeys.NoJsonCallback: Constants.NO_JSON_CALLBACK,
            ParameterKeys.PerPage: Constants.PER_PAGE ] as [String: AnyObject]
        
        let task = sharedInstance().taskForGETMethod(parameters) { result, error in
            var results: AnyObject? = nil
            
            if let photos = result.valueForKeyPath(JSONResponseKeys.PhotosKeyPath) as? [[String: AnyObject]] {
                results = photos as AnyObject
            }
            
            completionHandler(result: results, error: error)
        }
        
        task.resume()
        return task
    }
    
    
    
}