//
//  PyroEventSourceSessionProviderMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 23/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PyroEventSourceSessionProviderMock: PyroEventSourceSessionProviderProtocol {
    
    var queue: OperationQueue = OperationQueue()
    var headers: [String: String] = [:]
    
    func createSession(for delegate: URLSessionDataDelegate, lastEventID: String) -> URLSession {
        let session = URLSessionMock()
        session.shouldExecuteTaskResume = false
        return session
    }
}
