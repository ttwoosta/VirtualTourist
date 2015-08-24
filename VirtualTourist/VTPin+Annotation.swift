//
//  VTPin+Annotation.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import MapKit

extension VTPin {

    
    public var coordinate: CLLocationCoordinate2D {
        get {
            let lat = CLLocationDegrees(latitude.doubleValue)
            let long = CLLocationDegrees(longitude.doubleValue)
            let coordinate = CLLocationCoordinate2DMake(lat, long)
            return coordinate
        }
        set {
            latitude = NSNumber(double: newValue.latitude)
            longitude = NSNumber(double: newValue.longitude)
        }
    }
    
    public func pointAnnotation() -> VTPointAnnotation {
        
        // create a returned point annnotation
        var annotation = VTPointAnnotation(coord: coordinate, id: id)
        
        //annotation.title = annoTitle()
        //annotation.subtitle = annoSubtitle()
        //annotation.uniqueKey = uniqueKey
        
        return annotation
    }
    
}

