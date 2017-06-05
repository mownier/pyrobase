//
//  RequestResult.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 05/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public enum RequestResult {

    case failed(Error)
    case succeded(Any)
}

public enum RequestError: Error {
    
    case invalidURL
    case unparseableJSON
    case noURLResponse
}
