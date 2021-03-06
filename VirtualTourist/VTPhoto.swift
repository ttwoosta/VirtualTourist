//
//  VTPhoto.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/20/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData

public class VTPhoto: VTObject {

    @NSManaged public var title: String
    @NSManaged public var width: NSNumber
    @NSManaged public var height: NSNumber
    @NSManaged public var imageURL: NSURL
    @NSManaged public var owner: String
    @NSManaged public var secret: String
    @NSManaged public var pin: VTPin
    
    
    struct JSONKeys {
        static let Owner = "owner"
        static let Secret = "secret"
        static let Title = "title"
        static let ImageURL = "url_m"
        static let ImageWidth = "width_m"
        static let ImageHeight = "height_m"
        static let ID = "id"
    }
    
    public func decodeWith(dict: [String: AnyObject]) {
        if let titleString = dict[JSONKeys.Title] as? String {
            title = titleString
        }
        if let ownerString = dict[JSONKeys.Owner] as? String {
            owner = ownerString
        }
        if let secretString = dict[JSONKeys.Secret] as? String {
            secret = secretString
        }
        if let imageURLString = dict[JSONKeys.ImageURL] as? String {
            imageURL = NSURL(string: imageURLString)!
        }
        
        if let idValue = dict[JSONKeys.ID] as? String {
            id = idValue
        }
        if let widthValue = dict[JSONKeys.ImageWidth] as? NSString {
            if let widthFloat = widthValue.floatValue as Float! {
                width = NSNumber(float: widthFloat)
            }
        }
        if let heightValue = dict[JSONKeys.ImageHeight] as? NSString {
            if let heightFloat = heightValue.floatValue as Float! {
                height = NSNumber(float: heightFloat)
            }
        }
    }
    
    override public func prepareForDeletion() {
        super.prepareForDeletion()
        VTDataManager.Caches.imageCache.storeImage(nil, imageData: nil, withIdentifier: id)
    }
    
    var image: UIImage? {
        get {
            return VTDataManager.Caches.imageCache.imageWithIdentifier(id)
        }
    }
    
    func setImage(image: UIImage, imageData: NSData) {
        VTDataManager.Caches.imageCache.storeImage(image, imageData: imageData, withIdentifier: id)
    }
    
}
