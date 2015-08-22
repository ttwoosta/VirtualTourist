//
//  VTPointAnnotation.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import MapKit


public class VTPointAnnotation: MKPointAnnotation {
    
    public var uniqueKey: String!
    public var indexPath: NSIndexPath!
    
    public init(coord: CLLocationCoordinate2D) {
        super.init()
        coordinate = coord
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let anno = object as? VTPointAnnotation {
            if coordinate.latitude == anno.coordinate.latitude && coordinate.longitude == anno.coordinate.longitude {
                return true
            }
        }
        return false
    }
}