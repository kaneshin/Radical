// ShotRequest.swift
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

class ShotRequest: DribbbleRequest {
    
    enum List: String {
        case Debuts     = "debuts"
        case Everyone   = "everyone"
        case Popular    = "popular"
    }
    
    class func dispatch(component: Component, handlers: Handlers) -> ShotRequest {
        return ShotRequest().dispatch(component, handlers: handlers) as ShotRequest
    }
    
    /**
     * Returns the specified list of shots where :list has one of
     * the following values: debuts, everyone, popular
     * Parameters: Supports pagination
*/
    /**
    * GET /shots/:list
    *
    * @param list
    * @param pagination
    * @param handlers
    */
    class func list(list: List, pagination: Pagination, handlers: Handlers) -> ShotRequest {
        var component = Component(method: .GET, path: "/shots/\(list.rawValue)")
        component.parameters = pagination.toDictionary()
        return dispatch(component, handlers: handlers);
    }
    
}