//
//  PyroEventSourceSessionProviderTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 23/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroEventSourceSessionProviderTest: XCTestCase {
    
    func testCreate() {
        let provider = PyroEventSourceSessionProvider.create()
        XCTAssertEqual(provider.headers.count, 1)
        let accept = provider.headers["Accept"]
        XCTAssertNotNil(accept)
        XCTAssertEqual(accept!, "text/event-stream")
    }
    
    func testCreateSession() {
        let delegate = URLSessionDataDelegateMock()
        let provider = PyroEventSourceSessionProvider.create()
        var session = provider.createSession(for: delegate, lastEventID: "")
        XCTAssertNotNil(session.configuration.httpAdditionalHeaders)
        XCTAssertEqual(session.configuration.httpAdditionalHeaders as! [String: String], provider.headers)
        XCTAssertEqual(session.configuration.timeoutIntervalForRequest, TimeInterval(INT_MAX))
        XCTAssertEqual(session.configuration.timeoutIntervalForResource, TimeInterval(INT_MAX))
        XCTAssertTrue(session.delegate is URLSessionDataDelegateMock)
        
        XCTAssertNil(session.configuration.httpAdditionalHeaders!["Last-Event-Id"])
        
        let lastEventId = "12345"
        session = provider.createSession(for: delegate, lastEventID: lastEventId)
        XCTAssertNotNil(session.configuration.httpAdditionalHeaders!["Last-Event-Id"])
        XCTAssertEqual(session.configuration.httpAdditionalHeaders!["Last-Event-Id"] as! String, lastEventId)
    }
}
