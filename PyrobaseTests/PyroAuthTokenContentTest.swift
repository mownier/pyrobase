//
//  PyroAuthTokenContentTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 13/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroAuthTokenContentTest: XCTestCase {
    
    func testDescription() {
        let accessToken = "accessToken"
        let expiration = "3600"
        let refreshToken = "refreshToken"
        
        var content = PyroAuthTokenContent()
        content.accessToken = accessToken
        content.expiration = expiration
        content.refreshToken = refreshToken
        
        let expectedDescription = "accessToken: \(accessToken)\nexpiration: \(expiration)\nrefreshToken: \(refreshToken)"
        XCTAssertEqual(content.description, expectedDescription)
    }
}
