// RequestFixture.swift
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

import UIKit
import Radical

class RequestFixture: NSObject {
    
    let url = NSURL(string: "http://httpbin.org")!
    var method: Radical.Request.Method!

    enum Endpoint: String {
        case Default = "/"
        case Get = "/get"
        case Post = "/post"
    }
    
    private func endpoint() -> Endpoint {
        switch self.method! {
        case .GET:
            return Endpoint.Get
        case .POST:
            return Endpoint.Post
        default:
            return Endpoint.Default
        }
    }
    
    var component: Radical.Request.Component {
        return Radical.Request.Component(method: self.method, path: self.endpoint().rawValue)
    }
    
}
