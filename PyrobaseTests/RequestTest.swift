//
//  RequestTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class RequestTest: XCTestCase {
    
    func testRead() {
        let session = URLSessionMock()
        let operation = JSONRequestOperation()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        request.read(path: "https://foo.firebaseio.com/users/12345/name.json?access_token=accessToken") { value in
            XCTAssertTrue(value is String)
            XCTAssertEqual(value as! String, "Luche")
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithInt() {
        let session = URLSessionMock()
        let operation = JSONRequestOperation()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        request.read(path: "https://foo.firebaseio.com/users/12345/int.json?access_token=accessToken") { value in
            XCTAssertTrue(value is String)
            let number = Int(value as! String)
            XCTAssertNotNil(number)
            XCTAssertEqual(number, 101)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithDouble() {
        let session = URLSessionMock()
        let operation = JSONRequestOperation()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken") { value in
            XCTAssertTrue(value is String)
            let number = Double(value as! String)
            XCTAssertNotNil(number)
            XCTAssertEqual(number, 101.12345)
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
