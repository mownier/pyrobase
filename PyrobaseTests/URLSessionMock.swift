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
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSessionDataTaskMock(handler: completionHandler)
        task.handler = completionHandler
        task.result.data = content[url.absoluteString]?.data(using: .utf8)
        task.result.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        task.result.error = nil
        return task
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    
    class Result {
        
        var data: Data?
        var response: URLResponse?
        var error: Error?
    }
    
    var handler: (Data?, URLResponse?, Error?) -> Void
    var result: Result
    
    init(handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.handler = handler
        self.result = Result()
    }
    
    override func resume() {
        handler(result.data, result.response, result.error)
    }
}
