//
//  AuthRequestMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Pyrobase

class AuthRequestMock: RequestProtocol {

    var writeURLPath: String = ""
    var writeMethod: RequestMethod = .post
    var writeData: [AnyHashable: Any] = [:]
    
    func read(path: String, query: [AnyHashable : Any], completion: @escaping (RequestResult) -> Void) {
        
    }
    
    func write(path: String, method: RequestMethod, data: [AnyHashable : Any], completion: @escaping (RequestResult) -> Void) {
        writeURLPath = path
        writeMethod = method
        writeData = data
        completion(.succeeded(true))
    }
    
    func delete(path: String, completion: @escaping (RequestResult) -> Void) {
        
    }
}
