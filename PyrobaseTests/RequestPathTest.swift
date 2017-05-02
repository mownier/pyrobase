//
//  RequestPathTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class RequestPathTest: XCTestCase {
    
    func testInitialization() {
        let accessToken = "accessToken"
        let baseURL = "https://foo.firebaseio.com"
        let requestPath = RequestPath(baseURL: baseURL, accessToken: accessToken)
        XCTAssertNotNil(requestPath.baseURL)
        XCTAssertNotNil(requestPath.accessToken)
        XCTAssertEqual(requestPath.baseURL, baseURL)
        XCTAssertEqual(requestPath.accessToken, accessToken)
    }
    
    func testBuild() {
        let accessToken = "accessToken"
        let baseURL = "https://foo.firebaseio.com"
        let relativePath = "foo"
        let requestPath = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let requestURL = "\(baseURL)/\(relativePath).json?access_token=\(accessToken)"
        XCTAssertEqual(requestURL, requestPath.build(relativePath))
    }
}
