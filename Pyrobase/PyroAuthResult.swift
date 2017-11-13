//
//  PyroAuthResult.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 10/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public enum PyroAuthResult<T> {
    
    case failed(Error)
    case succeeded(T)
}

public enum PyroAuthError: Error {
    
    case unexpectedContent
    case incompleteContent
}

public struct PyroAuthContent {
    
    internal(set) public var userId: String
    internal(set) public var accessToken: String
    internal(set) public var email: String
    internal(set) public var refreshToken: String
    internal(set) public var expiration: String
    
    public init() {
        self.userId = ""
        self.accessToken = ""
        self.email = ""
        self.refreshToken = ""
        self.expiration = ""
    }
}

public struct PyroAuthTokenContent {
    
    internal(set) public var accessToken: String
    internal(set) public var expiration: String
    internal(set) public var refreshToken: String
    
    public init() {
        self.accessToken = ""
        self.expiration = ""
        self.refreshToken = ""
    }
}

extension PyroAuthContent: CustomStringConvertible {
    
    public var description: String {
        return "userId: \(userId)\naccessToken: \(accessToken)\nemail: \(email)\nrefreshToken: \(refreshToken)\nexpiration: \(expiration)"
    }
}

extension PyroAuthTokenContent: CustomStringConvertible {
    
    public var description: String {
        return "accessToken: \(accessToken)\nexpiration: \(expiration)\nrefreshToken: \(refreshToken)"
    }
}
