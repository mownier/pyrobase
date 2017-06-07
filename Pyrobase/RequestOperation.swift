//
//  RequestOperation.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 05/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestOperation {

    func build(url: URL, method: RequestMethod, data: [AnyHashable: Any]) -> URLRequest
    func parse(data: Data) -> RequestOperationResult
}

public enum RequestOperationResult {
    
    case error(Error)
    case okay(Any)
}

public class JSONRequestOperation: RequestOperation {
    
    public func build(url: URL, method: RequestMethod, data: [AnyHashable: Any]) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "\(method)"
        
        switch method {
        case .put, .post, .patch:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if !data.isEmpty {
                request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            }
            
        default:
            break
        }
        
        return request
    }
    
    public func parse(data: Data) -> RequestOperationResult {
        if JSONSerialization.isValidJSONObject(data) {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                return .error(RequestError.unparseableJSON)
            }
            
            return .okay(jsonObject)
            
        } else {
            guard let resultString = String(data: data, encoding: .utf8),
                let resultStringData = resultString.data(using: .utf8) else {
                return .error(RequestError.unparseableJSON)
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: resultStringData, options: []) else {
                return .okay(resultString)
            }
            
            return .okay(jsonObject)
        }
    }
}
