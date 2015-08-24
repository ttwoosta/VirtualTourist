//
//  VTPointAnnotation.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import MapKit


public class VTPointAnnotation: MKPointAnnotation {
    
    public var id: String!
    //public var indexPath: NSIndexPath!
    
    public init(coord: CLLocationCoordinate2D, id uniqueKey: String) {
        super.init()
        coordinate = coord
        id = uniqueKey
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let anno = object as? VTPointAnnotation {
            if id == anno.id {
                return true
            }
        }
        return false
    }
}