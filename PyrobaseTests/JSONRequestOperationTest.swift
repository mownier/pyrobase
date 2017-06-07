//
//  JSONRequestOperationTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 07/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class JSONRequestOperationTest: XCTestCase {
    
    func testBuildForGetMethod() {
        let operation = JSONRequestOperation.create()
        let url = URL(string: "https://foo.firebaseio.com/.json?accessToken=12345")!
        let request = operation.build(url: url, method: .get, data: [:])
        let headers = request.allHTTPHeaderFields!
        
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }
    
    func testBuildForPostMethod() {
        let operation = JSONRequestOperation.create()
        let url = URL(string: "https://foo.firebaseio.com/.json?accessToken=12345")!
        var request = operation.build(url: url, method: .post, data: [:])
        let headers = request.allHTTPHeaderFields!
        
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNil(request.httpBody)
        
        request = operation.build(url: url, method: .post, data: ["email": "me@me.com"])
        XCTAssertNotNil(request.httpBody)
    }
    
    func testBuildForPutMethod() {
        let operation = JSONRequestOperation.create()
        let url = URL(string: "https://foo.firebaseio.com/.json?accessToken=12345")!
        var request = operation.build(url: url, method: .put, data: [:])
        let headers = request.allHTTPHeaderFields!
        
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertNil(request.httpBody)
        
        request = operation.build(url: url, method: .put, data: ["email": "me@me.com"])
        XCTAssertNotNil(request.httpBody)
    }
    
    func testBuildForPatchMethod() {
        let operation = JSONRequestOperation.create()
        let url = URL(string: "https://foo.firebaseio.com/.json?accessToken=12345")!
        var request = operation.build(url: url, method: .patch, data: [:])
        let headers = request.allHTTPHeaderFields!
        
        XCTAssertEqual(headers.count, 2)
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(request.httpMethod, "PATCH")
        XCTAssertNil(request.httpBody)
        
        request = operation.build(url: url, method: .patch, data: ["email": "me@me.com"])
        XCTAssertNotNil(request.httpBody)
    }
    
    func testParse() {
        let operation = JSONRequestOperation.create()
        let param: [AnyHashable: Any] = ["email": "me@me.com"]
        let data = try? JSONSerialization.data(withJSONObject: param, options: [])
        let result = operation.parse(data: data!)

        switch result {
        case .error:
            XCTFail()
        
        case .okay(let info):
            XCTAssertTrue(info is [AnyHashable: Any])
            let resultInfo = info as! [AnyHashable: Any]
            XCTAssertEqual(resultInfo.count, 1)
            XCTAssertEqual(param["email"] as! String, resultInfo["email"] as! String)
        }
    }
    
    func testParseWithValidJSONObjectButHavingNilConvertedResult() {
        let mock = JSONSerializationMock.self
        mock.isValid = true
        mock.shouldThrowErrorOnJSONObjectConversion = true
        let operation = JSONRequestOperation(serialization: mock)
        let param: [AnyHashable: Any] = ["email": "me@me.com"]
        let data = try? JSONSerialization.data(withJSONObject: param, options: [])
        let result = operation.parse(data: data!)
        
        switch result {
        case .okay: XCTFail()
        case .error: break
        }
    }
    
    func testParseWithValidJSONObjectAndHavingNonNilConvertedResult() {
        let mock = JSONSerializationMock.self
        mock.isValid = true
        mock.shouldThrowErrorOnJSONObjectConversion = false
        mock.expectedJSONObject = ["message": "wee"]
        let operation = JSONRequestOperation(serialization: mock)
        let param: [AnyHashable: Any] = ["email": "me@me.com"]
        let data = try? JSONSerialization.data(withJSONObject: param, options: [])
        let result = operation.parse(data: data!)
        
        switch result {
        case .error: XCTFail()
        case .okay: break
        }
    }
    
    func testParseWithNonValidJSONObjectButNotUTF8Encoded() {
        let operation = JSONRequestOperation.create()
        let string = "Jeprox"
        let data = string.data(using: .utf32)
        let result = operation.parse(data: data!)
        
        switch result {
        case .okay:
            XCTFail()
        
        case .error(let info):
            XCTAssertTrue(info is RequestError)
            let errorInfo = info as! RequestError
            XCTAssertTrue(errorInfo == RequestError.unparseableJSON)
        }
    }
    
    func testCreate() {
        let operation = JSONRequestOperation.create()
        XCTAssertTrue(operation.serialization == JSONSerialization.self)
    }
}


