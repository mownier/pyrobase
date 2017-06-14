//
//  RequestMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Pyrobase

class RequestMock: RequestProtocol {

    var content: [AnyHashable: Any] = [
        "https://foo.firebaseio.com/name.json?auth=accessToken": "Luche",
        "https://foo.firebaseio.com/messages/abcde12345qwert.json?auth=accessToken": ["message": "Hello World!"]
    ]
    
    func read(path: String, query: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        completion(.succeeded(content[path]))
    }
    
    func write(path: String, method: RequestMethod, data: [AnyHashable : Any], completion: @escaping (RequestResult) -> Void) {
        switch method {
        case .put:
            content[path] = data
            completion(.succeeded(data))
        
        case .post:
            let newId = "abcde12345qwert"
            content[newId] = data
            completion(.succeeded(["name": newId]))
        
        case .patch:
            var contentInfo = content[path] as! [AnyHashable: Any]
            for (key, value) in data {
                contentInfo[key] = value
            }
            content[path] = contentInfo
            completion(.succeeded(data))
        
        default:
            break
        }
    }
    
    func delete(path: String, completion: @escaping (RequestResult) -> Void) {
        content.removeValue(forKey: path)
        completion(.succeeded("null"))
    }
}
