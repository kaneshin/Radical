// RequestTests.swift
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
import XCTest
import Radical

class RequestTests: XCTestCase {
    
    var fixture: RequestFixture!
    
    override func setUp() {
        super.setUp()
        self.fixture = RequestFixture()
    }
    
    override func tearDown() {
        self.fixture = nil
        super.tearDown()
    }
    
    func testGetRequest() {
        self.fixture.method = .GET

        let request = Radical.Request(url: self.fixture.url)
        let expectation = expectationWithDescription("\(self.fixture.url)")

        XCTAssertEqual(Radical.Request.Method.GET, self.fixture.method, "should be GET Request")
        
        request.dispatch(self.fixture.component)?.responseJSON(Radical.Request.Handlers(
            success: { (response, JSON) -> Void in
                XCTAssertNotNil(response, "response should not be nil")
            }, failure: { (response, error) -> Void in
                XCTAssertNil(error, "error should be nil")
            }, completion: { () -> Void in
                expectation.fulfill()
        }))
        XCTAssertNotNil(request, "request should not be nil")

        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "\(error)")
            
        })
        
    }
    
    func testPostRequest() {
        self.fixture.method = .POST

        let request = Radical.Request(url: self.fixture.url)
        let expectation = expectationWithDescription("\(self.fixture.url)")
        
        XCTAssertEqual(Radical.Request.Method.POST, self.fixture.method, "should be POST Request")
        
        request.dispatch(self.fixture.component)?.responseJSON(Radical.Request.Handlers(
            success: { (response, JSON) -> Void in
                XCTAssertNotNil(response, "response should not be nil")
            }, failure: { (response, error) -> Void in
                XCTAssertNil(error, "error should be nil")
            }, completion: { () -> Void in
                expectation.fulfill()
        }))
        XCTAssertNotNil(request, "request should not be nil")
        
        waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            XCTAssertNil(error, "\(error)")
            
        })
        
    }

}
