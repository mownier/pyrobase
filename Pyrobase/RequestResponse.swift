//
//  RequestResponse.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 22/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestResponseProtocol {
    
    func isErroneous(_ response: HTTPURLResponse?) -> Error?
}

public class RequestResponse: RequestResponseProtocol {

    public func isErroneous(_ response: HTTPURLResponse?) -> Error? {
        guard response != nil else {
            return nil
        }
        
        switch response!.statusCode {
        case 400: return RequestError.badRequest
        case 401: return RequestError.unauthorized
        case 403: return RequestError.forbidden
        case 404: return RequestError.notFound
        case 500: return RequestError.internalServiceError
        case 503: return RequestError.serviceUnavailable
        default: return nil
        }
    }
}
