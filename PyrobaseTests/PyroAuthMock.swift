//
//  PyroAuthMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 14/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PyroAuthMock: PyroAuth {

    static var defaultRequest: RequestProtocol = Request.create()
    static var defaultBundleIdentifier: String = ""
    static var defaultPlistName: String = ""
    
    override class func create(key: String, bundleIdentifier: String = "com.ner.Pyrobase", plistName: String = "PyroAuthInfo", request: RequestProtocol = Request.create() ) -> PyroAuth? {
        self.defaultRequest = request
        self.defaultBundleIdentifier = bundleIdentifier
        self.defaultPlistName = plistName
        
        return super.create(key: key, bundleIdentifier: bundleIdentifier, plistName: plistName, request: request)
    }
}
