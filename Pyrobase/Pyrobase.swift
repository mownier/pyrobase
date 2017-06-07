//
//  Pyrobase.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 01/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public class Pyrobase {
    
    internal var path: RequestPathProtocol
    internal var request: RequestProtocol
    
    public init(request: RequestProtocol, path: RequestPathProtocol) {
        self.request = request
        self.path = path
    }
    
    public func get(path relativePath: String, query: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        request.read(path: path.build(relativePath), query: query) { result in
            completion(result)
        }
    }
    
    public func put(path relativePath: String, value: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        request.write(path: path.build(relativePath), method: .put, data: value) { result in
            completion(result)
        }
    }
    
    public func post(path relativePath: String, value: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        request.write(path: path.build(relativePath), method: .post, data: value) { result in
            completion(result)
        }
    }
    
    public func patch(path relativePath: String, value: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        request.write(path: path.build(relativePath), method: .patch, data: value) { result in
            completion(result)
        }
    }
    
    public func delete(path: String, completion: @escaping (Bool, Any) -> Void) {
        
    }
}

extension Pyrobase {
    
    public class func create(baseURL: String, accessToken: String) -> Pyrobase {
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = Request.create()
        let pyrobase = Pyrobase(request: request, path: path)
        return pyrobase
    }
}
