//
//  PlistSerializationMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Foundation

class PlistSerializationMock: PropertyListSerialization {
    
    enum MockError: Error {
        
        case nilExpectedInfo
    }
    
    static var expectedInfo: Any?
    
    override class func propertyList(from data: Data, options opt: PropertyListSerialization.ReadOptions = [], format: UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>?) throws -> Any {
        guard expectedInfo != nil else {
            throw MockError.nilExpectedInfo
        }
        
        return expectedInfo!
    }
}
