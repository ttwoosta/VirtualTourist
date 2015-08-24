//
//  VTImageFetcher.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/21/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import UIKit

public class VTImageFetcher: NSObject, NSURLSessionDelegate {
    
    public struct ErrorDomain {
        static public let Client: String = "VTImageFetcherErrorDomain"
    }
    
    var URLSession: NSURLSession!
    var queue: NSOperationQueue!
    
    public class func sharedInstance() -> VTImageFetcher {
        struct Singleton {
            static var sharedInstance = VTImageFetcher()
        }
        return Singleton.sharedInstance
    }
    
    public override init() {
        super.init()
        
        // initialize session configuration with default template
        let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        // timeout for requests with be 30 second
        conf.timeoutIntervalForRequest = 30
        
        // maximun connection
        conf.HTTPMaximumConnectionsPerHost = 5
        
        // url cache configurations
        conf.requestCachePolicy = NSURLRequestCachePolicy.ReloadRevalidatingCacheData
        conf.URLCache = NSURLCache.sharedURLCache()
        
        // cookies configuration
        conf.HTTPShouldSetCookies = true
        conf.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        // additional headers
        // these headers are added to the request only if not already present.
        //conf.HTTPAdditionalHeaders = ["HTTP-": "HTTP-VALUE"]
        
        queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        URLSession = NSURLSession(configuration: conf, delegate: self, delegateQueue: queue)
    }
    
    public class func cancelAllTasks() {
        getDataTasksWithCompletionHandler() { dataTasks in
            for task in dataTasks as! [NSURLSessionTask] {
                task.cancel()
            }
        }
    }
    
    public class func downloadImageForURL(url: NSURL, completionHandler: (image: UIImage!, imageData: NSData!, error: NSError?) -> Void) -> NSURLSessionTask {
        // create url request
        let URLRequest = NSURLRequest(URL: url)
        
        // download image
        let task = sharedInstance().URLSession.dataTaskWithRequest(URLRequest) { data, response, error in
            
            if error != nil {
                completionHandler(image: nil, imageData: nil, error: error)
                return
            }
            
            // convert to Http response
            let httpRes = response as! NSHTTPURLResponse
            
            if httpRes.statusCode == 200 {
                if let image = UIImage(data: data) {
                    completionHandler(image: image, imageData: data, error: nil)
                }
                else {
                    // create no image error
                    let httpError = NSError(domain: ErrorDomain.Client,
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "An error occur when initialize image"])
                    completionHandler(image: nil, imageData: nil, error: httpError)
                }
            }
            else {
                let httpError = NSError(domain: ErrorDomain.Client,
                    code: httpRes.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpRes.statusCode)])
                completionHandler(image: nil, imageData: nil, error: httpError)
            }
            
        }
        
        task.resume()
        return task
    }
    
    public class func getDataTasksWithCompletionHandler( completionHandler: (dataTasks: [AnyObject]!) -> Void ) {
        sharedInstance().URLSession.getTasksWithCompletionHandler() { data, upload, download in
            completionHandler(dataTasks: data)
        }
    }
    
    public class func fetchImageForURL(url: NSURL, getImageHandler: (image: UIImage!, imageData: NSData!, error: NSError?) -> Void, completionHandler: () -> Void) -> NSURLSessionTask {
        
        let task = downloadImageForURL(url) { image, imageData, error in
            dispatch_async(dispatch_get_main_queue()) {
                getImageHandler(image: image, imageData: imageData, error: error)
            }
            self.getDataTasksWithCompletionHandler() { dataTasks in
                if dataTasks.count == 0 {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler()
                    }
                }
            }
        }
        
        return task
    }

}