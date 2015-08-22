//
//  VTSerializableRegion.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import MapKit

public class VTSerializableRegion: NSObject, NSCoding {
    
    struct CodingKeys {
        static let CenterLatitude = "center.latitude"
        static let CenterLongitude = "center.longitude"
        
        static let SpanLatitubeDelta = "span.latitudeDelta"
        static let SpanLongitudeDelta = "span.longitudeDelta"
    }
    
    public var coordinateRegion: MKCoordinateRegion!
    
    public init(coordinateRegion: MKCoordinateRegion) {
        super.init()
        self.coordinateRegion = coordinateRegion
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init()
        
        let centerLat: CLLocationDegrees = aDecoder.decodeDoubleForKey(CodingKeys.CenterLatitude)
        let centerLong: CLLocationDegrees = aDecoder.decodeDoubleForKey(CodingKeys.CenterLongitude)
        
        let spanLat: CLLocationDegrees = aDecoder.decodeDoubleForKey(CodingKeys.SpanLatitubeDelta)
        let spanLong: CLLocationDegrees = aDecoder.decodeDoubleForKey(CodingKeys.SpanLongitudeDelta)
        
        let centerCoord = CLLocationCoordinate2DMake(centerLat, centerLong)
        let span = MKCoordinateSpanMake(spanLat, spanLong)
        coordinateRegion = MKCoordinateRegionMake(centerCoord, span)
    }
    
     public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(coordinateRegion.center.latitude, forKey: CodingKeys.CenterLatitude)
        aCoder.encodeDouble(coordinateRegion.center.longitude, forKey: CodingKeys.CenterLongitude)
        
        aCoder.encodeDouble(coordinateRegion.span.latitudeDelta, forKey: CodingKeys.SpanLatitubeDelta)
        aCoder.encodeDouble(coordinateRegion.span.longitudeDelta, forKey: CodingKeys.SpanLongitudeDelta)
    }
    
}