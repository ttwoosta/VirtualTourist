//
//  VTPin.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class VTPin: NSManagedObject {

    @NSManaged public var created: NSDate
    @NSManaged public var longitude: NSNumber
    @NSManaged public var latitude: NSNumber
    @NSManaged public var name: String
    @NSManaged public var photos: [VTPhoto]
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        created = NSDate()
    }

}
