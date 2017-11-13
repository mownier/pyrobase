//
//  PyroEventSourceSessionProvider.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 22/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol PyroEventSourceSessionProviderProtocol {
    
    var queue: OperationQueue { get }
    var headers: [String: String] { set get }
    
    func createSession(for delegate: URLSessionDataDelegate, lastEventID: String) -> URLSession
}

public class PyroEventSourceSessionProvider: PyroEventSourceSessionProviderProtocol {
    
    public var queue: OperationQueue
    public var headers: [String: String]
    
    public class func create() -> PyroEventSourceSessionProvider {
        let queue = OperationQueue()
        let headers = [
            "Accept": "text/event-stream"
        ]
        return PyroEventSourceSessionProvider(queue: queue, headers: headers)
    }
    
    public init(queue: OperationQueue, headers: [String: String]) {
        self.queue = queue
        self.headers = headers
    }
    
    public func createSession(for delegate: URLSessionDataDelegate, lastEventID: String) -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        config.timeoutIntervalForResource = TimeInterval(INT_MAX)
        config.httpAdditionalHeaders = headers
        if !lastEventID.isEmpty {
            config.httpAdditionalHeaders!["Last-Event-Id"] = lastEventID
        }
        return URLSession(configuration: config, delegate: delegate, delegateQueue: queue)
    }
}
