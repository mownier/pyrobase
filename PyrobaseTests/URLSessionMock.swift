//
//  URLSessionMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import Foundation

class URLSessionMock: URLSession {

    var content = [
        "https://foo.firebaseio.com/users/12345/name.json?access_token=accessToken": "Luche",
        "https://foo.firebaseio.com/users/12345/int.json?access_token=accessToken": "101",
        "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken": "101.12345"
    ]
    
    var expectedDataTaskResult: URLSessionDataTaskMock.Result?
    var shouldExecuteTaskResume: Bool = true
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let url = request.url!
        let task = URLSessionDataTaskMock(handler: completionHandler)
        task.handler = completionHandler
        
        if expectedDataTaskResult != nil {
            task.result = expectedDataTaskResult!
            
        } else {
            task.result.data = content[url.absoluteString]?.data(using: .utf8)
            task.result.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            task.result.error = nil
        }

        return task
    }
    
    override func dataTask(with url: URL) -> URLSessionDataTask {
        let task = URLSessionDataTaskMock(httpResponse: nil)
        task.shouldExecuteResume = shouldExecuteTaskResume
        return task
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    
    enum TaskMockError: Error {
        
        case mockError1
    }
    
    class Result {
        
        var data: Data?
        var response: URLResponse?
        var error: Error?
    }
    
    var handler: (Data?, URLResponse?, Error?) -> Void
    var result: Result
    var httpResponse: HTTPURLResponse?
    var shouldExecuteResume: Bool = true
    
    override var response: URLResponse? {
        return httpResponse
    }
    
    init(handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.handler = handler
        self.result = Result()
    }
    
    convenience init(httpResponse: HTTPURLResponse?) {
        let handler: (Data?, URLResponse?, Error?) -> Void = { _, _, _ in }
        self.init(handler: handler)
        self.httpResponse = httpResponse
    }
    
    override func resume() {
        guard shouldExecuteResume else {
            return
        }
        
        handler(result.data, result.response, result.error)
    }
}
