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

public class VTPin: VTObject {

    @NSManaged public var created: NSDate
    @NSManaged public var longitude: NSNumber
    @NSManaged public var latitude: NSNumber
    @NSManaged private var flickrPage: NSNumber // default page id will be 1
    @NSManaged public var photos: [VTPhoto]
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        created = NSDate()
        id = NSUUID().UUIDString
    }
    
    public var flikrSearchNextPageValue: Int {
        return  flikrSearchPage + 1
    }
    
    public var flikrSearchPage: Int {
        get {
            return flickrPage.integerValue
        }
        set {
            flickrPage = NSNumber(integer: newValue)
        }
    }

}
