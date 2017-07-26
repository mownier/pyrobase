//
//  RequestResult.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 05/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public enum RequestResult {

    case failed(Error)
    case succeeded(Any)
}

public enum RequestError: Error {
    
    case invalidURL
    case unparseableJSON
    case noURLResponse
    case nullJSON
    case unknown
    
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case internalServiceError(String)
    case serviceUnavailable(String)

    public var code: Int {
        switch self {
        case .invalidURL: return -9000
        case .unparseableJSON: return -9001
        case .noURLResponse: return -9002
        case .nullJSON: return -9003
        case .unknown: return -9004
        case .badRequest: return -9005
        case .unauthorized: return -9006
        case .forbidden: return -9007
        case .notFound: return -9008
        case .internalServiceError: return -9009
        case .serviceUnavailable: return -9010
        }
    }
    
    public var message: String {
        switch self {
        case .invalidURL: return "URL is invalid"
        case .unparseableJSON: return "Can not parse JSON"
        case .noURLResponse: return "No URL response"
        case .nullJSON: return "JSON is null"
        case .unknown: return "Unknown error encountered"
            
        case .badRequest(let message),
             .unauthorized(let message),
             .forbidden(let message),
             .notFound(let message),
             .internalServiceError(let message),
             .serviceUnavailable(let message):
            return message
        }
    }
}

extension RequestError: Equatable {
    
    public static func ==(lhs: RequestError, rhs: RequestError) -> Bool {
        return lhs.code == rhs.code && lhs.message == rhs.message
    }
}
