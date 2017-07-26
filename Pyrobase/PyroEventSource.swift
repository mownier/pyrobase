//
//  PyroEventSource.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 20/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public enum PyroEventSourceError: Error {
    
    case notClosed
    case notOpen
    case forcedClose
}

public enum PyroEventSourceState {
    
    case connecting
    case open
    case closed
}

public protocol PyroEventSourceCallback: class {
    
    func pyroEventSourceOnConnecting(_ eventSource: PyroEventSource)
    func pyroEventSourceOnOpen(_ eventSource: PyroEventSource)
    func pyroEventSourceOnClosed(_ eventSource: PyroEventSource)
    func pyroEventSource(_ eventSource: PyroEventSource, didReceiveMessage message: PyroEventSourceMessage)
    func pyroEventSource(_ eventSource: PyroEventSource, didReceiveError error: Error)
}

public class PyroEventSource: NSObject {

    internal var path: RequestPathProtocol
    internal var response: RequestResponseProtocol
    internal var sessionProvider: PyroEventSourceSessionProviderProtocol
    internal var parser: PyroEventSourceParserProtocol
    internal var session: URLSession!
    internal(set) public var lastEventID: String
    internal(set) public var state: PyroEventSourceState {
        didSet {
            switch state {
            case .open: callback?.pyroEventSourceOnOpen(self)
            case .closed: callback?.pyroEventSourceOnClosed(self)
            case .connecting: callback?.pyroEventSourceOnConnecting(self)
            }
        }
    }
    
    weak public var callback: PyroEventSourceCallback?
    
    public class func create(baseURL: String, accessToken: String, lastEventID: String = "") -> PyroEventSource {
        let provider = PyroEventSourceSessionProvider.create()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let parser = PyroEventSourceParser()
        let response = RequestResponse()
        let eventSource = PyroEventSource(path: path, response: response, sessionProvider: provider, parser: parser, lastEventID: lastEventID)
        return eventSource
    }
    
    public init(path: RequestPathProtocol, response: RequestResponseProtocol, sessionProvider: PyroEventSourceSessionProvider, parser: PyroEventSourceParserProtocol, lastEventID: String) {
        self.path = path
        self.response = response
        self.sessionProvider = sessionProvider
        self.lastEventID = lastEventID
        self.state = .closed
        self.parser = parser
    }
    
    public func close() {
        session?.invalidateAndCancel()
        session = nil
        state = .closed
    }
    
    public func stream(_ relativePath: String) {
        guard state == .closed else {
            callback?.pyroEventSource(self, didReceiveError: PyroEventSourceError.notClosed)
            return
        }
        
        guard let url = URL(string: path.build(relativePath)) else {
            callback?.pyroEventSource(self, didReceiveError: RequestError.invalidURL)
            return
        }
        
        session = sessionProvider.createSession(for: self, lastEventID: lastEventID)
        state = .connecting
        session.dataTask(with: url).resume()
    }
    
    internal func isForcedClose(_ response: HTTPURLResponse?) -> Bool {
        return response != nil && response!.statusCode == 204
    }
}

extension PyroEventSource: URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, dataTask task: URLSessionDataTask, didReceive data: Data) {
        guard state == .open else {
            callback?.pyroEventSource(self, didReceiveError: PyroEventSourceError.notOpen)
            return
        }
        
        guard !isForcedClose(task.response as? HTTPURLResponse) else {
            close()
            callback?.pyroEventSource(self, didReceiveError: PyroEventSourceError.forcedClose)
            return
        }
        
        if let responseError = response.isErroneous(task.response as? HTTPURLResponse, data: data) {
            close()
            callback?.pyroEventSource(self, didReceiveError: responseError)
            
        } else {
            let message = parser.parse(data)
            callback?.pyroEventSource(self, didReceiveMessage: message)
            lastEventID = message.id
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask task: URLSessionDataTask, didReceive httpResponse: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let responseError = response.isErroneous(httpResponse as? HTTPURLResponse, data: nil) {
            close()
            callback?.pyroEventSource(self, didReceiveError: responseError)
            
        } else {
            state = .open
            completionHandler(.allow)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        close()
        
        guard !isForcedClose(task.response as? HTTPURLResponse) else {
            callback?.pyroEventSource(self, didReceiveError: PyroEventSourceError.forcedClose)
            return
        }
        
        if let responseError = response.isErroneous(task.response as? HTTPURLResponse, data: nil) {
            callback?.pyroEventSource(self, didReceiveError: responseError)
        }
    }
}
