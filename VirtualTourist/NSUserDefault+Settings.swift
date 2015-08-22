//
//  NSUserDefault+Settings.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import MapKit

extension NSUserDefaults {
    
    struct DefaultKeys {
        static let CoordinateRegion = "coordinateRegion"
    }
    
    public func setDefaultRegion(coordinateRegion: MKCoordinateRegion) {
        let serializeRegion = VTSerializableRegion(coordinateRegion: coordinateRegion)
        let data = NSKeyedArchiver.archivedDataWithRootObject(serializeRegion)
        setObject(data, forKey: DefaultKeys.CoordinateRegion)
    }
    
    public func defaultRegion() -> MKCoordinateRegion! {
        if let data = objectForKey(DefaultKeys.CoordinateRegion) as? NSData {
            if let serializeRegion = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? VTSerializableRegion {
                return serializeRegion.coordinateRegion
            }
        }
        return nil
    }
    
    
}