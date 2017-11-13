//
//  PyroEventSourceMessageTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 23/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroEventSourceMessageTest: XCTestCase {
    
    func testDescription() {
        var message = PyroEventSourceMessage()
        message.id = "1"
        message.event = "put"
        message.data = "hello world"
        XCTAssertEqual(message.description, "\nid: 1\nevent: put\ndata: hello world\n")
    }
}
