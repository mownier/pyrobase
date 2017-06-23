//
//  RequestResponseTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 23/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class RequestResponseTest: XCTestCase {
    
    func testIsErroneous() {
        let response = RequestResponse()
        
        var httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        var error = response.isErroneous(httpResponse)
        XCTAssertNotNil(error)
        XCTAssertTrue(error as! RequestError == .badRequest)
    
        httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        error = response.isErroneous(httpResponse)
        XCTAssertNotNil(error)
        XCTAssertTrue(error as! RequestError == .unauthorized)
    
        httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 403, httpVersion: nil, headerFields: nil)!
        error = response.isErroneous(httpResponse)
        XCTAssertNotNil(error)
        XCTAssertTrue(error as! RequestError == .forbidden)
    
        httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        error = response.isErroneous(httpResponse)
        XCTAssertNotNil(error)
        XCTAssertTrue(error as! RequestError == .notFound)
        
        httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        error = response.isErroneous(httpResponse)
        XCTAssertNotNil(error)
        XCTAssertTrue(error as! RequestError == .internalServiceError)
        
        httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 503, httpVersion: nil, headerFields: nil)!
        error = response.isErroneous(httpResponse)
        XCTAssertNotNil(error)
        XCTAssertTrue(error as! RequestError == .serviceUnavailable)
        
        httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        error = response.isErroneous(httpResponse)
        XCTAssertNil(error)
        XCTAssertNil(response.isErroneous(nil))
    }
}
