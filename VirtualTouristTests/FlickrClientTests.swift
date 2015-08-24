//
//  FlickrClientTests.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData
import VirtualTourist
import XCTest
import MapKit

class FlickrClientTests: XCTestCase {

    func test_url_parameters() {
        let parameters = [FlickrClient.ParameterKeys.Extras: FlickrClient.Constants.EXTRAS,
            FlickrClient.ParameterKeys.Method: FlickrClient.Constants.METHOD_NAME,
            FlickrClient.ParameterKeys.SafeSearch: FlickrClient.Constants.SAFE_SEARCH,
            FlickrClient.ParameterKeys.Format: FlickrClient.Constants.DATA_FORMAT,
            FlickrClient.ParameterKeys.NoJsonCallback: FlickrClient.Constants.NO_JSON_CALLBACK] as [String: AnyObject]
        
        
        let task = FlickrClient.sharedInstance().taskForGETMethod(parameters) { result, error in
        
        }
        
        let URLRequest = task.originalRequest
        XCTAssertNotNil(URLRequest)
        let URL = URLRequest.URL
        XCTAssertNotNil(URL)
        let URLString: String! = URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.flickr.com/services/rest/?method=flickr.photos.search&nojsoncallback=1&extras=url_m&safe_search=1&format=json&api_key=03306dd4495f07e3d053ce1f4ae7ce8a")
        
    }
    
    func test_bounding_box() {
        
        let bbox = FlickrClient.createBoundingBoxString(50, longitude: -50)
        XCTAssertEqual(bbox, "-51.0,49.0,-49.0,51.0")
        
        let bbox1 = FlickrClient.createBoundingBoxString(100, longitude: 100)
        XCTAssertEqual(bbox1, "99.0,99.0,101.0,90.0")
        
        let bbox2 = FlickrClient.createBoundingBoxString(-91, longitude: 180)
        XCTAssertEqual(bbox2, "179.0,-90.0,180.0,-90.0")
    }
    
    func test_search_photos_for_coordinate() {
        let coord = CLLocationCoordinate2DMake(37.331565189999999, -122.03057969)
        
        let expectation = self.expectationWithDescription(nil)
        
        FlickrClient.searchPhotosByCoodinate(coord, page: nil) { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            
            let photos = result as! [[String: AnyObject]]
            XCTAssertEqual(photos.count, 50)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func ___test_search_photo_fail() {
        let coord = CLLocationCoordinate2DMake(37.331565189999999, -122.03057969)
        
        let expectation = self.expectationWithDescription(nil)
        
        FlickrClient.searchPhotosByCoodinate(coord, page: nil) { result, error in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            
            let err: NSError! = error
            XCTAssertEqual(err.code, 100)
            XCTAssertEqual(err.localizedDescription, "Invalid API Key (Key has invalid format)")
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    

}
