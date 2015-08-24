//
//  VTPhotoTransformer.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import CoreData
import UIKit

extension VTPhoto {
    
    public override class func initialize() {
        super.initialize()
        
        let urlTransformer = VTURLTransformer()
        NSValueTransformer.setValueTransformer(urlTransformer, forName: "VTURLTransformer")
    }
    
}

public class VTURLTransformer: NSValueTransformer {
    
    // information that can be used to analyze available transformer instances (especially used inside Interface Builder)
    
    // class of the "output" objects, as returned by transformedValue:
    override public class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    // flag indicating whether transformation is read-only or not
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(value: AnyObject?) -> AnyObject? {
        
        if let url = value as? NSURL {
            return url.absoluteString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        return nil
    }
    
    override public func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        if let strData = value as? NSData {
            if let urlString = NSString(data: strData, encoding: NSUTF8StringEncoding) as? String {
                return NSURL(string: urlString)
            }
        }
        
        return nil
    }
    
}
