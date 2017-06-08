//
//  RequestOperationMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 08/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Pyrobase

class RequestOperationMock: RequestOperation {

    enum MockError: Error {
        
        case failedToParse
    }
    
    func build(url: URL, method: RequestMethod, data: [AnyHashable : Any]) -> URLRequest {
        return URLRequest(url: url)
    }
    
    func parse(data: Data) -> RequestOperationResult {
        return .error(MockError.failedToParse)
    }
}
