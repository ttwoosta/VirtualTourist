//
//  SerializeRegionTests.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData
import VirtualTourist
import XCTest
import MapKit

class SerializeRegion: XCTestCase {
    
    var region: MKCoordinateRegion!
    
    override func setUp() {
        super.setUp()
        
        let span = MKCoordinateSpanMake(1.51, 2.53)
        let center = CLLocationCoordinate2DMake(-50.321, 124.67)
        region = MKCoordinateRegionMake(center, span)
    }

    func test_serialize_region() {
        
        let serRegion = VTSerializableRegion(coordinateRegion: region)
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(serRegion)
        XCTAssertNotNil(data)
        
        let deserRegion = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! VTSerializableRegion
        XCTAssertNotNil(deserRegion)
        
        let deRegion = deserRegion.coordinateRegion
        XCTAssertEqual(deRegion.center.latitude, -50.321)
        XCTAssertEqual(deRegion.center.longitude, 124.67)
        XCTAssertEqual(deRegion.span.latitudeDelta, 1.51)
        XCTAssertEqual(deRegion.span.longitudeDelta, 2.53)
    }
    
    func test_user_default() {
        
        NSUserDefaults.standardUserDefaults().setDefaultRegion(region)
        
        let deRegion = NSUserDefaults.standardUserDefaults().defaultRegion()
        XCTAssertEqual(deRegion.center.latitude, -50.321)
        XCTAssertEqual(deRegion.center.longitude, 124.67)
        XCTAssertEqual(deRegion.span.latitudeDelta, 1.51)
        XCTAssertEqual(deRegion.span.longitudeDelta, 2.53)
        
    }
}
