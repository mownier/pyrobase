//
//  JSONSerializationMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 07/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Foundation

class JSONSerializationMock: JSONSerialization {
    
    enum MockError: Error {
        
        case throwError1
    }
    
    static var isValid: Bool = true
    static var shouldThrowErrorOnJSONObjectConversion: Bool = true
    static var expectedJSONObject: Any = ""
    
    override class func isValidJSONObject(_ obj: Any) -> Bool {
        return true
    }
    
    override class func jsonObject(with data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> Any {
        guard shouldThrowErrorOnJSONObjectConversion else {
            return expectedJSONObject
        }
        
        throw MockError.throwError1
    }
}
