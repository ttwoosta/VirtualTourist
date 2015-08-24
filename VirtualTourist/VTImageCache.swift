
//
//  VTImageCache.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

//
//  ImageCache.swift
//  FavoriteActors
//
//  Created by Jason on 1/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class VTImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        // construct path with identifier
        let path = pathForIdentifier(identifier!)
        
        // First try the memory cache
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            if let image = UIImage(data: data) {
                inMemoryCache.setObject(image, forKey: path)
                return image
            }
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, imageData: NSData?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And in documents directory
        imageData?.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    
    lazy var cacheDirURL: NSURL = {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let URL = documentsDirectoryURL.URLByAppendingPathComponent("imagesCache")
        
        // create cache directory
        NSFileManager.defaultManager().createDirectoryAtURL(URL, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        return URL
    }()
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = self.cacheDirURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}