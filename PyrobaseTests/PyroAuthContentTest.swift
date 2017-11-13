//
//  PyroAuthContentTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 13/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroAuthContentTest: XCTestCase {
    
    func testDescription() {
        let accessToken = "accessToken"
        let expiration = "3600"
        let refreshToken = "refreshToken"
        let userId = "me12345"
        let email = "me@me.com"
        
        var content = PyroAuthContent()
        content.accessToken = accessToken
        content.expiration = expiration
        content.refreshToken = refreshToken
        content.userId = userId
        content.email = email
        
        let expectedDescription = "userId: \(userId)\naccessToken: \(accessToken)\nemail: \(email)\nrefreshToken: \(refreshToken)\nexpiration: \(expiration)"
        XCTAssertEqual(content.description, expectedDescription)
    }
}
