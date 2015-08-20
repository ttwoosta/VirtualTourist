//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/19/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation

public class FlickrClient: BaseClient {
    // shared session
    var session: NSURLSession
    
    //////////////////////////////////
    // MARK: Singleton
    /////////////////////////////////
    
    public class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //////////////////////////////////
    // MARK: API
    /////////////////////////////////
    
    public func taskForGETMethod(parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.API_KEY
        
        let URLString = Constants.BASE_URL + FlickrClient.escapedParameters(mutableParameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }
    
    //////////////////////////////////
    // MARK: Shared methods
    /////////////////////////////////
    
    public func taskForRequest(URLRequest: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(URLRequest) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = FlickrClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else {
                let httpRes = response as! NSHTTPURLResponse
                
                if httpRes.statusCode == 200 || httpRes.statusCode == 201 {
                    FlickrClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
                else {
                    let newError = FlickrClient.errorForData(data, response: response, error: downloadError)
                    completionHandler(result: nil, error: newError)
                }
            }
        }
        
        return task
    }
    
    public override class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        }
        else {
            // check for error response
            if let result = parsedResult as? [String: AnyObject] {
                if let status = result[JSONErrorKeys.Status] as? String {
                    if status == "fail" {
                        let error = errorForData(data, response: nil, error: nil)
                        completionHandler(result: nil, error: error)
                        return
                    }
                }
            }
            
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    public class func errorForData(data: NSData!, response: NSURLResponse!, error: NSError!) -> NSError {
        
        if data != nil {
            if let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
                if let code = result[JSONErrorKeys.Code] as? Int {
                    if let errorMessage = result[JSONErrorKeys.Message] as? String {
                        let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                        return NSError(domain: ErrorDomain.Client, code: code, userInfo: userInfo)
                    }
                }
            }
        }
        
        // server doesn't known what error occurs
        // refer to response status code
        if let httpRes = response as? NSHTTPURLResponse {
            if httpRes.statusCode > 300 {
                return NSError(domain: ErrorDomain.Client,
                    code: httpRes.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpRes.statusCode)])
            }
        }
        
        return error
    }
}