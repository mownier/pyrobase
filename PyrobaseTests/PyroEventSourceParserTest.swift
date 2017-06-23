//
//  PyroEventSourceParserTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 23/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroEventSourceParserTest: XCTestCase {
    
    func testParseWithDataNotUTF8Encoded() {
        let parser = PyroEventSourceParser()
        let data = "id: 1\nevent: put\ndata: hello world\n\n".data(using: .utf32)!
        let message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
    }
    
    func testParseWithEmptyEventString() {
        let parser = PyroEventSourceParser()
        let data = "\n\n\n\n".data(using: .utf8)!
        let message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
    }
    
    func testParseWithColonAsPrefix() {
        let parser = PyroEventSourceParser()
        let data = ":\n: wee\n: toinks\n\n".data(using: .utf8)!
        let message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
    }
    
    func testParseWithRetryString() {
        let parser = PyroEventSourceParser()
        var data = "retry: 3600\n\n".data(using: .utf8)!
        var message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
        
        data = "id: retry:\n\n".data(using: .utf8)!
        message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
    }
    
    func testParseWithNoColon() {
        let parser = PyroEventSourceParser()
        let data = "id\n\n".data(using: .utf8)!
        let message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
    }
    
    func testParseWithValidData() {
        let parser = PyroEventSourceParser()
        var data = "id: 1\nevent: put\ndata: hello world\n\n".data(using: .utf8)!
        var message = parser.parse(data)
        XCTAssertEqual(message.id, "1")
        XCTAssertEqual(message.event, "put")
        XCTAssertEqual(message.data, "hello world")
        
        data = "foo: 1\nbar: put\nwee: hello world\n\n".data(using: .utf8)!
        message = parser.parse(data)
        XCTAssertTrue(message.id.isEmpty)
        XCTAssertTrue(message.event.isEmpty)
        XCTAssertTrue(message.data.isEmpty)
    }
}
