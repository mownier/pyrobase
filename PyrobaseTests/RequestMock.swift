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
    
    func read(path: String, completion: @escaping (Any) -> Void) {
        completion(content[path])
    }
    
    func write(path: String, type: RequestWriteType, data: [AnyHashable : Any], completion: @escaping (RequestResult) -> Void) {
    }
}
