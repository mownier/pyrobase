//
//  RequestResponse.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 22/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestResponseProtocol {
    
    func isErroneous(_ response: HTTPURLResponse?, data: Data?) -> Error?
}

public class RequestResponse: RequestResponseProtocol {

    private(set) public var serializer: JSONSerialization.Type
    
    public init(serializer: JSONSerialization.Type = JSONSerialization.self) {
        self.serializer = serializer
    }
    
    public func isErroneous(_ response: HTTPURLResponse?, data: Data?) -> Error? {
        guard response != nil else {
            return nil
        }
        
        switch response!.statusCode {
        case 400: return RequestError.badRequest(errorMessage(data))
        case 401: return RequestError.unauthorized(errorMessage(data))
        case 403: return RequestError.forbidden(errorMessage(data))
        case 404: return RequestError.notFound(errorMessage(data))
        case 500: return RequestError.internalServiceError(errorMessage(data))
        case 503: return RequestError.serviceUnavailable(errorMessage(data))
        default: return nil
        }
    }
    
    func errorMessage(_ data: Data?) -> String {
        guard data != nil else {
            return ""
        }
        
        let info = (try? serializer.jsonObject(with: data!, options: [])) as? [AnyHashable: Any]
        return (info?["error"] as? String) ?? ""
    }
}
