//
//  VirtualTouristTests.swift
//  VirtualTouristTests
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData
import VirtualTourist
import XCTest

class DataModelTests: XCTestCase {
    
    var moc: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        // get managed object context from shared data manager
        moc = VTDataManager.sharedInstance().managedObjectContext
        XCTAssertNotNil(moc)
        
        // remove all change for every test
        moc.reset()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //////////////////////////////////
    //  MARK: Initialize CoreData objects
    /////////////////////////////////
    
    func test_insert_a_pin() {
        let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Pin, inManagedObjectContext: moc)!
        XCTAssertNotNil(entity, "Pin entity cannot found")
        
        let pin = VTPin(entity: entity, insertIntoManagedObjectContext: moc)
        XCTAssertNotNil(pin, "Pin can't be initializes")
        XCTAssertTrue(pin.isKindOfClass(VTPin))
    }
    
    func test_insert_a_photo() {
        let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Photo, inManagedObjectContext: moc)!
        XCTAssertNotNil(entity, "Photo entity cannot found")
        
        let photo = VTPhoto(entity: entity, insertIntoManagedObjectContext: moc)
        XCTAssertNotNil(photo, "Photo can't be initializes")
        XCTAssertTrue(photo.isKindOfClass(VTPhoto))
    }
    
    func test_relationship() {
        let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Pin, inManagedObjectContext: moc)!
        let pin = VTPin(entity: entity, insertIntoManagedObjectContext: moc)
        
        let photoEntity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Photo, inManagedObjectContext: moc)!
        
        for i in 0...5 {
            let photo = VTPhoto(entity: photoEntity, insertIntoManagedObjectContext: moc)
            photo.pin = pin
        }
        
        let photos = pin.photos
        XCTAssertEqual(photos.count, 6)
    }
    
    //////////////////////////////////
    //  MARK: Photo decode
    /////////////////////////////////
    
    func get_photos_json_fixture() -> [[String: AnyObject]]! {
        let bundle = NSBundle(forClass: self.dynamicType)
        let fixtureURL = bundle.URLForResource("PhotosJson.json", withExtension: nil)
        XCTAssertNotNil(fixtureURL)
        
        let jsonData = NSData(contentsOfURL: fixtureURL!)!
        XCTAssertNotNil(jsonData)
        
        if let result = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: nil) as? NSDictionary {
            if let photos = result.valueForKeyPath("photos.photo") as? [[String: AnyObject]] {
                return photos
            }
        }
        
        return nil
    }
    
    func test_photo_decode() {
        let fixtures = get_photos_json_fixture()
        XCTAssertNotNil(fixtures)
        XCTAssertEqual(fixtures.count, 50)
        
        let first = fixtures.first
        
        let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Photo, inManagedObjectContext: moc)!
        let photo = VTPhoto(entity: entity, insertIntoManagedObjectContext: moc)
        
        if let dict = fixtures.first {
            photo.decodeWith(dict)
        }
        
        XCTAssertEqual(photo.title, "Come to Leopolds in the next 45 minutes if you want an ass kicking cc @rcrowley")
        XCTAssertEqual(photo.owner, "8790317@N03")
        XCTAssertEqual(photo.secret, "2894e27ddf")
        XCTAssertEqual(photo.imageURL.absoluteString!, "https://farm1.staticflickr.com/746/20723764255_2894e27ddf.jpg")
        XCTAssertEqual(photo.width.floatValue, 500)
        XCTAssertEqual(photo.height.floatValue, 375)
        XCTAssertEqual(photo.id.integerValue, 20723764255)
       
    }
    
    //////////////////////////////////
    //  MARK: Image Transformer
    /////////////////////////////////
    
    func get_photo_fixture() -> NSData {
        // // create bundle and get fixture
        let bundle = NSBundle(forClass: self.dynamicType)
        let fixtureURL = bundle.URLForResource("test_photo.jpg", withExtension: nil)
        XCTAssertNotNil(fixtureURL)
        
        let data = NSData(contentsOfURL: fixtureURL!)
        XCTAssertNotNil(data)
        
        return data!
    }
    
    func create_an_photo_for_testing() {
        
        let entity = NSEntityDescription.entityForName(VTDataManager.EntityNames.Photo, inManagedObjectContext: moc)!
        let photo = VTPhoto(entity: entity, insertIntoManagedObjectContext: moc)
        photo.title = "testing_photo"
        XCTAssertNotNil(photo, "Photo can't be initializes")
        
        let data = get_photo_fixture()
        let image = UIImage(data: data)
        XCTAssertNotNil(image)
        
        photo.image = image!
        
        let pImage = photo.image
        XCTAssertNotNil(pImage)
        
        VTDataManager.sharedInstance().saveContext()
    }
    
    func get_testing_photo_object() -> VTPhoto {
        let fetchRequest = NSFetchRequest(entityName: "VTPhoto")
        fetchRequest.predicate = NSPredicate(format: "title == %@", "testing_photo")
        fetchRequest.fetchLimit = 1
        
        return moc.executeFetchRequest(fetchRequest, error: nil)?.last as! VTPhoto
    }
    
    func test_photo_transformer() {
        create_an_photo_for_testing()
        moc.reset()
        
        // photo objects
        let photo = get_testing_photo_object()
        let image = photo.image
        let data = UIImageJPEGRepresentation(image, 1.0)
        
        // fixture objects
        let cmpData = get_photo_fixture()
        let cmpImage = UIImage(data: cmpData)!
        
        println(data.length)
        println(cmpData.length)
        
        //XCTAssertEqual(data, cmpData)
        XCTAssertEqual(cmpImage.size, image!.size)
        
        
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtURL(VTDataManager.sharedInstance().dataStoreURL, error: nil)
    }
    
    
    
}
