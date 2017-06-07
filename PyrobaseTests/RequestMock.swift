//
//  RequestMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Pyrobase

class RequestMock: RequestProtocol {

    var content = [
        "https://foo.firebaseio.com/name.json?access_token=accessToken": "Luche"
    ]
    
    func read(path: String, query: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        completion(.succeeded(content[path]))
    }
    
    func write(path: String, method: RequestMethod, data: [AnyHashable : Any], completion: @escaping (RequestResult) -> Void) {
    }
}
