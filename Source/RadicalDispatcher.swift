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
    
    public var defaultSessionManager: Manager?
    public var backgroundSessionManager: Manager?
    
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
        if let handlers = radicalRequest.handlers {
            if error != nil {
                handlers.failure?(response, error)
            } else {
                handlers.success?(response, object)
            }
            handlers.completion?()
        }
    }
    
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
                        request?.responseJSON({ (urlRequest: NSURLRequest, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
                            self.centralProcessResponse(urlRequest, response: response, object: object, error: error, radicalRequest: radicalRequest)
                        })
                    case .Upload:
                        let parameterEncoding = ParameterEncoding.URL
                        let nsurlRequest = NSMutableURLRequest(URL: url)
                        nsurlRequest.HTTPMethod = component.method.rawValue
                        if let data = component.data {
                            switch data {
                            case .Data(let data):
                                let urlRequest = parameterEncoding.encode(nsurlRequest, parameters: parameters).0
                                let dataUrl = RadicalDispatcher.multipartFormData(nsurlRequest, data: data, fileName: "image", parameterName: "image")
                                request = sessionManager?.upload(urlRequest, file: dataUrl)
                            case .Stream(let stream):
                                let urlRequest = parameterEncoding.encode(nsurlRequest, parameters: parameters).0
                                request = sessionManager?.upload(urlRequest, stream: stream)
                            case .URL(let url):
                                let urlRequest = parameterEncoding.encode(nsurlRequest, parameters: parameters).0
                                request = sessionManager?.upload(urlRequest, file: url)
                            }
                        }
                        request?.progress(closure: { (bytesSend, totalBytesSend, totalBytesExpectedToWrite) -> Void in
                            let progress = Float(totalBytesSend) / Float(totalBytesExpectedToWrite)
                            println("Progress : \(progress)")
                            radicalRequest.handlers?.progress?(progress)
                            return
                        })
//                        request?.responseJSON({ (urlRequest: NSURLRequest, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
//                            self.centralProcessResponse(urlRequest, response: response, object: object, error: error, radicalRequest: radicalRequest)
//                        })
                        request?.response({ (request, response, object, error) -> Void in
                            self.centralProcessResponse(request, response: response, object: object, error: error, radicalRequest: radicalRequest)
                        })
                    case .Download:
                        let parameterEncoding = ParameterEncoding.URL
                        let nsurlRequest = NSMutableURLRequest(URL: url)
                        nsurlRequest.HTTPMethod = component.method.rawValue
                        let urlRequest = parameterEncoding.encode(nsurlRequest, parameters: parameters).0
                        request = sessionManager?.download(urlRequest, destination: { (url: NSURL, urlResponse: NSHTTPURLResponse) -> (NSURL) in
                            return component.downloadDestination ?? NSURL()
                        })
                        request?.progress(closure: { (bytesRead, totalBytesRead, totalBytesExpectedToWrite) -> Void in
                            radicalRequest.handlers?.progress?(Float(totalBytesRead) / Float(totalBytesExpectedToWrite))
                            return
                        })
                        request?.responseJSON({ (urlRequest: NSURLRequest, response: NSHTTPURLResponse?, object: AnyObject?, error: NSError?) -> Void in
                            self.centralProcessResponse(urlRequest, response: response, object: object, error: error, radicalRequest: radicalRequest)
                        })
                    }
                    request?.resume()
                }
            }
        }
    }
    
    class func multipartFormData(request: NSMutableURLRequest,data: NSData,fileName: String,parameterName: String) -> NSURL {

        /*
        // boundary に任意の文字列を設定します．
        let boundary = "-boundary"
        let post = "muukii"
        
        let fileNameUploaded = "image"
        let nameUploaded = "image"
        
        // POST multipart/form-data のボディ部分を作成します．
        let dataSend = NSMutableData()
        dataSend.appendData(NSString(string: "--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "Content-Disposition: form-data; name=\"status\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "\(post)").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "Content-Disposition: form-data; name=\"\(nameUploaded)\"; filename=\"\(fileNameUploaded)\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "Content-Type: image/png\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(data)
        dataSend.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        dataSend.appendData(NSString(string: "--\(boundary)--\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        // POST リクエストを作成します．
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//        [request setHTTPMethod:@"POST"];
//        [request setHTTPBody:dataSend];
        request.HTTPBody = dataSend
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
*/
        let fileName = ""
        let signatureFile = NSTemporaryDirectory() + "/" + fileName
        data.writeToFile(signatureFile, atomically: true)
        
//        while (![[NSFileManager defaultManager] fileExistsAtPath:signatureFile]) {
//            [NSThread sleepForTimeInterval:.5];
//        }
        
        request.HTTPMethod = "POST"
        request.addValue("image/png", forHTTPHeaderField: "Content-Type")
    
        return NSURL(fileURLWithPath: signatureFile)!
    }
}
