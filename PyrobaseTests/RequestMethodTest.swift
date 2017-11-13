//
//  RequestMethodTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 07/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class RequestMethodTest: XCTestCase {
    
    func testPrintedDescription() {
        var method: RequestMethod = .get
        XCTAssertEqual("\(method)", "GET")
        
        method = .post
        XCTAssertEqual("\(method)", "POST")
        
        method = .put
        XCTAssertEqual("\(method)", "PUT")
        
        method = .patch
        XCTAssertEqual("\(method)", "PATCH")
        
        method = .delete
        XCTAssertEqual("\(method)", "DELETE")
    }
}
