//
//  RequestErrorTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 26/07/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class RequestErrorTest: XCTestCase {
    
    func testCode() {
        XCTAssertEqual(RequestError.invalidURL.code, -9000)
        XCTAssertEqual(RequestError.unparseableJSON.code, -9001)
        XCTAssertEqual(RequestError.noURLResponse.code, -9002)
        XCTAssertEqual(RequestError.nullJSON.code, -9003)
        XCTAssertEqual(RequestError.unknown.code, -9004)
        
        XCTAssertEqual(RequestError.badRequest("").code, -9005)
        XCTAssertEqual(RequestError.unauthorized("").code, -9006)
        XCTAssertEqual(RequestError.forbidden("").code, -9007)
        XCTAssertEqual(RequestError.notFound("").code, -9008)
        XCTAssertEqual(RequestError.internalServiceError("").code, -9009)
        XCTAssertEqual(RequestError.serviceUnavailable("").code, -9010)
    }
    
    func testMessage() {
        XCTAssertEqual(RequestError.invalidURL.message, "URL is invalid")
        XCTAssertEqual(RequestError.unparseableJSON.message, "Can not parse JSON")
        XCTAssertEqual(RequestError.noURLResponse.message, "No URL response")
        XCTAssertEqual(RequestError.nullJSON.message, "JSON is null")
        XCTAssertEqual(RequestError.unknown.message, "Unknown error encountered")
        
        XCTAssertEqual(RequestError.badRequest("Bad request").message, "Bad request")
        XCTAssertEqual(RequestError.unauthorized("Unauthorized").message, "Unauthorized")
        XCTAssertEqual(RequestError.forbidden("Forbidden").message, "Forbidden")
        XCTAssertEqual(RequestError.notFound("Not Found").message, "Not Found")
        XCTAssertEqual(RequestError.internalServiceError("Internal Service Error").message, "Internal Service Error")
        XCTAssertEqual(RequestError.serviceUnavailable("Service Unavailable").message, "Service Unavailable")
    }
    
    func testEquality() {
        XCTAssertEqual(RequestError.invalidURL, RequestError.invalidURL)
        XCTAssertNotEqual(RequestError.invalidURL, RequestError.noURLResponse)
        XCTAssertNotEqual(RequestError.invalidURL, RequestError.badRequest("Bad request"))
        XCTAssertEqual(RequestError.badRequest("Bad request"), RequestError.badRequest("Bad request"))
        XCTAssertNotEqual(RequestError.badRequest("Bad request"), RequestError.badRequest("Worse request"))
        XCTAssertNotEqual(RequestError.badRequest("Bad request"), RequestError.unauthorized("Unauthorized"))
    }
}

