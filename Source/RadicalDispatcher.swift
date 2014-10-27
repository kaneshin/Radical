//
//  RadicalDispatcher.swift
//  Radical
//
//  Created by Hiroshi Kimura on 10/27/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import Foundation
import Alamofire



public class RadicalDispatcher: NSObject {
    public enum SessionType {
        case Default
        case Background
    }
    
    public class var sharedInstance: RadicalDispatcher {
        struct Singleton {
            static let instance = RadicalDispatcher()
        }
        return Singleton.instance
    }
    public override init() {
        super.init()
        self.defaultSessionManager = Manager.sharedInstance
        
        let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("radical.background_session")
        self.backgroundSessionManager = Manager(configuration: backgroundSessionConfiguration)
    }
    
    public func appendParameters(parameters: [String : AnyObject]?) -> [String : AnyObject]? {
        return parameters
    }
    
    public func centralProcessResponse(request: NSURLRequest, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?, radicalRequest: RadicalRequest) {
        
    }
    
    public var defaultSessionManager: Manager?
    public var backgroundSessionManager: Manager?
    
    public func dispath(radicalRequest: RadicalRequest,sessionType: SessionType) {
        if let component = radicalRequest.component {
            var sessionManager: Manager?
            switch sessionType {
            case .Default:
                sessionManager = self.defaultSessionManager
            case .Background:
                sessionManager = self.backgroundSessionManager
            }
            let parameters = self.appendParameters(component.parameters)
            if let urlString = radicalRequest.URL?.absoluteString?.stringByAppendingPathComponent("\(component.path)") {
                if let url = NSURL(string: urlString) {
                    var request: Request?
                    switch component.taskType {
                    case .Data:
                        request = sessionManager?.request(component.method, url, parameters: parameters, encoding: ParameterEncoding.URL)
                        request?.responseJSON({ (request: NSURLRequest, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
                            self.centralProcessResponse(request, response: response, object: object, error: error, radicalRequest: radicalRequest)
                        })
                    case .Upload:
                        let parameterEncoding = ParameterEncoding.URL
                        let nsurlRequest = NSMutableURLRequest(URL: url)
                        nsurlRequest.HTTPMethod = component.method.rawValue
                        let urlRequest = parameterEncoding.encode(nsurlRequest, parameters: parameters).0
                        if let data = component.data {
                            switch data {
                            case .Data(let data):
                                request = sessionManager?.upload(urlRequest, data: data)
                            case .Stream(let stream):
                                request = sessionManager?.upload(urlRequest, stream: stream)
                            case .URL(let url):
                                request = sessionManager?.upload(urlRequest, file: url)
                            }
                        }
                        request?.responseJSON({ (url: NSURLRequest?, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
                            
                        })
                    case .Download:
                        let parameterEncoding = ParameterEncoding.URL
                        let nsurlRequest = NSMutableURLRequest(URL: url)
                        nsurlRequest.HTTPMethod = component.method.rawValue
                        let urlRequest = parameterEncoding.encode(nsurlRequest, parameters: parameters).0
                        request = sessionManager?.download(urlRequest, destination: { (url: NSURL, urlResponse: NSHTTPURLResponse) -> (NSURL) in
                            return component.downloadDestination ?? NSURL()
                        })
                    }
                    request?.progress(closure: { (bytesRead, totalBytesRead, totalBytesExpectedToWrite) -> Void in
                        println("\(bytesRead),\(totalBytesRead),\(totalBytesExpectedToWrite)")
                    })
                    request?.resume()
                }
            }
        }
    }
}
