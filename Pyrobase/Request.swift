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
    internal var response: RequestResponseProtocol
    
    public init(session: URLSession, operation: RequestOperation, response: RequestResponseProtocol) {
        self.session = session
        self.operation = operation
        self.response = response
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
        guard let url = buildURL(path, method, data) else {
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
            
            let error = self.response.isErroneous(response as? HTTPURLResponse, data: data)
            
            guard error == nil else {
                completion(.failed(error!))
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
    
    internal func buildURL(_ path: String, _ method: RequestMethod, _ data: [AnyHashable: Any]) -> URL? {
        switch method {
        case .get where !data.isEmpty:
            guard !path.isEmpty, var components = URLComponents(string: path) else {
                return nil
            }
            
            var queryItems = [URLQueryItem]()
            
            for (key, value) in data {
                let item = URLQueryItem(name: "\(key)", value: "\(value)")
                queryItems.insert(item, at: 0)
            }
            
            if components.queryItems != nil {
                components.queryItems!.append(contentsOf: queryItems)
                
            } else {
                components.queryItems = queryItems
            }
            
            return components.url
            
        default:
            return URL(string: path)
        }
    }
}

extension Request {
    
    public class func create() -> Request {
        let session = URLSession.shared
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        return request
    }
}
