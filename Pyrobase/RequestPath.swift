//
//  RequestPath.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol RequestPathProtocol {

    var baseURL: String { get }
        
    func build(_ path: String) -> String
}

public class RequestPath: RequestPathProtocol {
    
    internal var accessToken: String
    
    public var baseURL: String
    
    public init(baseURL: String, accessToken: String) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }
    
    public func build(_ path: String) -> String {
        return "\(baseURL)/\(path).json?access_token=\(accessToken)"
    }
}
