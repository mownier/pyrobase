//
//  RequestMethod.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 05/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public enum RequestMethod {
    
    case get
    case put
    case patch
    case post
}

extension RequestMethod: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .get: return "GET"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .post: return "POST"
        }
    }
}
