//
//  Request.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestProtocol {
    
    func read(path: String, completion: @escaping (RequestResult) -> Void)
    func write(path: String, method: RequestMethod, data: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void)
}

public class Request: RequestProtocol {
    
    internal var session: URLSession
    internal var operation: RequestOperation
    
    public init(session: URLSession, operation: RequestOperation) {
        self.session = session
        self.operation = operation
    }
    
    public func read(path: String, completion: @escaping (RequestResult) -> Void) {
        guard let url = URL(string: path) else {
            completion(.failed(RequestError.invalidURL))
            return
        }
        
        let request = operation.build(url: url, method: .get, data: [:])
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
                completion(.succeded([:]))
                return
            }
            
            let result = self.operation.parse(data: data!)
            
            switch result {
            case .error(let info): completion(.failed(info))
            case .okay(let info): completion(.succeded(info))
            }
        }
        task.resume()
    }
    
    public func write(path: String, method: RequestMethod, data: [AnyHashable: Any], completion: @escaping (RequestResult) -> Void) {
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
                completion(.succeded([:]))
                return
            }
            
            let result = self.operation.parse(data: data!)
            
            switch result {
            case .error(let info): completion(.failed(info))
            case .okay(let info): completion(.succeded(info))
            }
        }
        task.resume()
    }
}

extension Request {
    
    public class func create() -> Request {
        let session = URLSession.shared
        let operation = JSONRequestOperation()
        let request = Request(session: session, operation: operation)
        return request
    }
}
