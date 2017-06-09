//
//  Request.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestProtocol {
    
    func read(path: String, query: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void)
    func write(path: String, method: RequestMethod, data: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void)
    func delete(path: String, completion: @escaping (RequestResult) -> Void)
}

public class Request: RequestProtocol {
    
    internal var session: URLSession
    internal var operation: RequestOperation
    
    public init(session: URLSession, operation: RequestOperation) {
        self.session = session
        self.operation = operation
    }
    
    public func read(path: String, query: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        request(path, .get, query, completion)
    }
    
    public func write(path: String, method: RequestMethod, data: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
        request(path, method, data, completion)
    }
    
    public func delete(path: String, completion: @escaping (RequestResult) -> Void) {
        request(path, .delete, [:], completion)
    }
    
    internal func request(_ path: String, _ method: RequestMethod, _ data: [AnyHashable: Any], _ completion: @escaping (RequestResult) -> Void) {
        guard let url = URL(string: path) else {
            completion(.failed(RequestError.invalidURL))
            return
        }
        
        let request = operation.build(url: url, method: method, data: data)
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failed(error!))
                return
            }
            
            guard response != nil else {
                completion(.failed(RequestError.noURLResponse))
                return
            }
            
            guard data != nil else {
                completion(.succeeded([:]))
                return
            }
            
            let result = self.operation.parse(data: data!)
            
            switch result {
            case .error(let info):
                completion(.failed(info))
                
            case .okay(let info):
                guard let okayInfo = info as? String, okayInfo.lowercased() == "null", method != .delete else {
                    completion(.succeeded(info))
                    return
                }
                
                completion(.failed(RequestError.nullJSON))
            }
        }
        task.resume()
    }
}

extension Request {
    
    public class func create() -> Request {
        let session = URLSession.shared
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        return request
    }
}
