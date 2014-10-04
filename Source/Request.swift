// Request.swift
//
// Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire

public class Request: NSObject {

    public struct Component {
        public var method: Method
        public var path: String
        public var parameters: [String : AnyObject]?
        public var data: NSData?
        public init(method: Method, path: String) {
            self.method = method
            self.path = path
        }
    }
    
    public typealias Success = ((NSHTTPURLResponse?, AnyObject?) -> Void)
    public typealias Failure = ((NSHTTPURLResponse?, NSError?) -> Void)
    public typealias Completion = (() -> Void)

    public struct Handlers {
        var success: Success?
        var failure: Failure?
        var completion: Completion?
        public init(success: Success? = nil, failure: Failure? = nil, completion: Completion? = nil) {
            self.success = success
            self.failure = failure
            self.completion = completion
        }
    }

    // MARK: - Essential
    
    private var URL: NSURL!
    private var request: Alamofire.Request?
    
    public init(url: NSURL) {
        super.init()
        self.URL = url
    }

    public func suspend() {
        self.request?.suspend()
    }

    public func resume() {
        self.request?.resume()
    }
    
    public func cancel() {
        self.request?.cancel()
    }
    
    // MARK: - Procedure
    
    public func dispatch(component: Component) -> Alamofire.Request! {
        let url = NSURL(string: component.path, relativeToURL: self.URL)!
        self.request = Alamofire.request(component.method, url.absoluteString!, parameters: component.parameters)
        return self.request
    }
    
    public func upload(component: Component) -> Alamofire.Request! {
        let url = NSURL(string: component.path, relativeToURL: self.URL)!
        self.request = Alamofire.upload(component.method, url.absoluteString!, component.data!)
        return self.request
    }

    // MARK: - Feature
    
    public func forward() {}
    public func redirect() {}

    // MARK: - Manager (Reserved)
    
    class Manager {
        class var sharedInstance: Manager {
            struct Singleton {
                static let instance = Manager()
            }
            return Singleton.instance
        }
    }

    // MARK: - Extends Alamofire
    
    public typealias Method = Alamofire.Method
    
}

// MARK: - Extends Alamofire

extension Alamofire.Request {
    
    public func responseJSON(handlers: Request.Handlers) -> Self {
        return self.responseJSON { (request, response, JSON, error) -> Void in
            if error != nil {
                handlers.failure?(response, error)
            } else {
                handlers.success?(response, JSON)
            }
            handlers.completion?()
        }
    }
    
}
