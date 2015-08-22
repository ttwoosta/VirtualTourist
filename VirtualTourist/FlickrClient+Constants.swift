//
//  FlickrClient+Constants.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation


extension FlickrClient {
    
    public struct ErrorDomain {
        static public let Client: String = "FlickrClientErrorDomain"
    }
    
    public struct Constants {
        
        static public let BASE_URL = "https://api.flickr.com/services/rest/"
        static public let METHOD_NAME = "flickr.photos.search"
        static public let API_KEY = "03306dd4495f07e3d053ce1f4ae7ce8a"
        //static public let API_KEY = "testing_api_key"
        
        static public let EXTRAS = "url_m"
        static public let SAFE_SEARCH = 1
        static public let DATA_FORMAT = "json"
        static public let NO_JSON_CALLBACK = 1
        static public let PER_PAGE = 21
    }
    
    public struct ParameterKeys {
        static public let ApiKey = "api_key"
        static public let Method = "method"
        static public let BoundingBox = "bbox"
        static public let SafeSearch = "safe_search"
        static public let Extras = "extras"
        static public let Format = "format"
        static public let NoJsonCallback = "nojsoncallback"
        static public let PerPage = "per_page"
    }
    
    public struct BoundingBox {
        static public let HalfWidth: Double = 1.0
        static public let HalfHeight: Double = 1.0
    }
    
    public struct Latitude {
        static public let Min: Double = -90
        static public let Max: Double = 90
    }
    
    public struct Longitude {
        static public let Min: Double = -180
        static public let Max: Double = 180
    }
    
    public struct JSONErrorKeys {
        static public let Code: String = "code"
        static public let Message: String = "message"
        static public let Status: String = "stat"
    }
    
    public struct JSONResponseKeys {
        static public let PhotosKeyPath: String = "photos.photo"
        static public let Pages: String = "pages"
        static public let Total: String = "total"
                
    }
    
}