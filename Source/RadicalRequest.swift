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

public class RadicalRequest: NSObject {
    public enum TaskType {
        case Data
        case Download
        case Upload
    }
    
    public enum UploadData {
        case Data(NSData)
        case Stream(NSInputStream)
        case URL(NSURL)
    }
    
    public struct Component {
        public var method: Method
        public var path: String
        public var parameters: [String : AnyObject]?
        public var taskType: TaskType
        public var data: UploadData?
        public var downloadDestination: NSURL?
        public init(method: Method, path: String) {
            self.method = method
            self.path = path
            self.taskType = .Data
        }
    }
    
    public typealias Progress = ((Float) -> Void)
    public typealias Success = ((NSHTTPURLResponse?, AnyObject?) -> Void)
    public typealias Failure = ((NSHTTPURLResponse?, NSError?) -> Void)
    public typealias Completion = (() -> Void)

    public struct Handlers {
        public var progress: Progress?
        public var success: Success?
        public var failure: Failure?
        public var completion: Completion?

        public init(success: Success? = nil, failure: Failure? = nil, completion: Completion? = nil) {
            self.progress
            self.success = success
            self.failure = failure
            self.completion = completion
        }
    }
    
    public var component: Component?
    public var handlers: Handlers?

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
    
    // MARK: - Extends Alamofire
    public typealias Method = Alamofire.Method
}

// MARK: - Extends Alamofire

extension Alamofire.Request {
    public func responseJSON(handlers: RadicalRequest.Handlers) -> Self {
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
