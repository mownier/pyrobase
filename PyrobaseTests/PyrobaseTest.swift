//
//  PyrobaseTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 01/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyrobaseTest: XCTestCase {
    
    func testInitialization() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let requestPath = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = Request.create()
        let pyrobase = Pyrobase(baseURL: baseURL, accessToken: accessToken, requestPath: requestPath, request: request)
        XCTAssertNotNil(pyrobase.baseURL)
        XCTAssertNotNil(pyrobase.accessToken)
        XCTAssertNotNil(pyrobase.requestPath)
        XCTAssertNotNil(pyrobase.request)
        XCTAssertEqual(pyrobase.baseURL, baseURL)
        XCTAssertEqual(pyrobase.accessToken, accessToken)
    }
    
    func testCreate() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let pyrobase = Pyrobase.create(baseURL: baseURL, accessToken: accessToken)
        XCTAssertNotNil(pyrobase.baseURL)
        XCTAssertNotNil(pyrobase.accessToken)
        XCTAssertNotNil(pyrobase.requestPath)
        XCTAssertEqual(pyrobase.baseURL, baseURL)
        XCTAssertEqual(pyrobase.accessToken, accessToken)
        XCTAssertTrue(pyrobase.requestPath is RequestPath)
    }
    
    func testGet() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let requestPath = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(baseURL: baseURL, accessToken: accessToken, requestPath: requestPath, request: request)
        
        let expectation1 = expectation(description: "testGet")
        pyrobase.get(path: "name") { result in
            switch result {
            case .failed:
                XCTFail()
            
            case .succeeded(let data):
                XCTAssertTrue(data is String)
                XCTAssertEqual(data as! String, "Luche")
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testPut() {
        
    }
}
