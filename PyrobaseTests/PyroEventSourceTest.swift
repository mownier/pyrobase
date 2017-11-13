//
//  PyroEventSourceTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 21/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroEventSourceTest: XCTestCase {

    var eventSource: PyroEventSource!
    
    var isCalledOpenCallback: Bool = false
    var isCalledClosedCallback: Bool = false
    var isCalledConnectingCallback: Bool = false
    
    var expectedPyroEventSourceError: PyroEventSourceError?
    var expectedRequestError: RequestError?
    var expectedMessage: PyroEventSourceMessage?
    
    override func setUp() {
        isCalledOpenCallback = false
        isCalledClosedCallback = false
        isCalledConnectingCallback = false
    }
    
    func testCreate() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        
        let path = eventSource.path as! RequestPath
        
        XCTAssertEqual(path.baseURL, baseURL)
        XCTAssertEqual(path.accessToken, accessToken)
        
        XCTAssertNil(eventSource.callback)
        XCTAssertNil(eventSource.session)
        XCTAssertTrue(eventSource.lastEventID.isEmpty)
        
        XCTAssertTrue(eventSource.parser is PyroEventSourceParser)
        XCTAssertTrue(eventSource.response is RequestResponse)
        XCTAssertTrue(eventSource.state == .closed)
        
        let lastEventID = "abcde12345qwert"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken, lastEventID: lastEventID)
        XCTAssertEqual(eventSource.lastEventID, lastEventID)
    }
    
    func testClose() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        
        eventSource.close()
        
        XCTAssertFalse(isCalledClosedCallback)
        XCTAssertNil(eventSource.session)
        XCTAssertTrue(eventSource.state == .closed)
        
        eventSource.callback = self
        eventSource.close()
        XCTAssertTrue(isCalledClosedCallback)
    }
    
    func testStateDidSetObserver() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.callback = self
        eventSource.state = .open
        eventSource.state = .closed
        eventSource.state = .connecting
        
        XCTAssertTrue(isCalledOpenCallback)
        XCTAssertTrue(isCalledClosedCallback)
        XCTAssertTrue(isCalledConnectingCallback)
    }
    
    func testIsForcedClose() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        var httpResponse = HTTPURLResponse(url: URL(string: baseURL)!, statusCode: 204, httpVersion: nil, headerFields: nil)
        var isForcedClose = eventSource.isForcedClose(httpResponse)
        XCTAssertTrue(isForcedClose)
        
        httpResponse = HTTPURLResponse(url: URL(string: baseURL)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        isForcedClose = eventSource.isForcedClose(httpResponse)
        XCTAssertFalse(isForcedClose)
    }
    
    func testStreamWithNotClosedError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.callback = self
        expectedPyroEventSourceError = PyroEventSourceError.notClosed
        
        eventSource.state = .open
        eventSource.stream("users/abcde12345qwert")
        
        eventSource.state = .connecting
        eventSource.stream("users/abcde12345qwert")
    }
    
    func testStreamWithInvalidURLError() {
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: "", accessToken: accessToken)
        eventSource.callback = self
        expectedRequestError = RequestError.invalidURL
        
        eventSource.stream("users/abcde12345qwert")
        eventSource.stream("")
    }
    
    func testStreamWithConnectingState() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.callback = self
        eventSource.stream("users/abcde12345qwert")
        XCTAssertTrue(eventSource.state == .connecting)
        XCTAssertNotNil(eventSource.session)
    }
    
    func testURLSessionDidReceiveDataWithNotOpenError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        let data = Data(bytes: [0,1,1,2,3,5,8])
        expectedPyroEventSourceError = PyroEventSourceError.notOpen
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.callback = self
        eventSource.urlSession(session, dataTask: task, didReceive: data)
    }
    
    func testURLSessionDidReceiveDataWithForcedCloseError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 204, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        let data = Data(bytes: [0,1,1,2,3,5,8])
        expectedPyroEventSourceError = PyroEventSourceError.forcedClose
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, dataTask: task, didReceive: data)
    }
    
    func testURLSessionDidReceiveDataWithErroneousHTTPURLResponse() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        let data = Data(bytes: [0,1,1,2,3,5,8])
        expectedRequestError = RequestError.internalServiceError("")
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, dataTask: task, didReceive: data)
    }
    
    func testURLSessionDidReceiveDataShouldCallOnReceiveMessage() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        let string = "id: 1\nevent: put\ndata: hello world\n\n"
        let data = string.data(using: .utf8)!
        expectedMessage = PyroEventSourceMessage()
        expectedMessage?.id = "1"
        expectedMessage?.event = "put"
        expectedMessage?.data = "hello world"
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, dataTask: task, didReceive: data)
        XCTAssertEqual(eventSource.lastEventID, expectedMessage!.id)
    }
    
    func testURLSessionDidReceiveRepsonseWithErroneousHTTPURLResponse() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        let completion: (URLSession.ResponseDisposition) -> Void = { _ in }
        expectedRequestError = RequestError.internalServiceError("")
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, dataTask: task, didReceive: httpResponse!, completionHandler: completion)
    }
    
    func testURLSessionDidReceiveResponseWithOpenState() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        let expectation1 = expectation(description: "testURLSessionDidReceiveResponse")
        let completion: (URLSession.ResponseDisposition) -> Void = { disposition in
            XCTAssertTrue(disposition == .allow)
            XCTAssertTrue(self.eventSource.state == .open)
            expectation1.fulfill()
        }
        expectedRequestError = RequestError.internalServiceError("")
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, dataTask: task, didReceive: httpResponse!, completionHandler: completion)
        waitForExpectations(timeout: 10)
    }
    
    func testURLSessionDidCompleteWithForcedCloseError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 204, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        expectedPyroEventSourceError = PyroEventSourceError.forcedClose
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, task: task, didCompleteWithError: nil)
    }
    
    func testURLSessionDidCompleteWithNilError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, task: task, didCompleteWithError: nil)
    }
    
    func testURLSessionDidCompleteWithErroneousHTTPURLResponse() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let session = URLSession()
        let httpResponse = HTTPURLResponse(url: URL(string: "https://sampleio.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let task = URLSessionDataTaskMock(httpResponse: httpResponse)
        expectedRequestError = RequestError.internalServiceError("")
        eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
        eventSource.state = .open
        eventSource.callback = self
        eventSource.urlSession(session, task: task, didCompleteWithError: nil)
    }
}

extension PyroEventSourceTest: PyroEventSourceCallback {
    
    func pyroEventSource(_ eventSource: PyroEventSource, didReceiveError error: Error) {
        XCTAssertTrue(eventSource == self.eventSource)
        
        if expectedPyroEventSourceError != nil {
            XCTAssertTrue(error is PyroEventSourceError)
            let eventSourceError = error as! PyroEventSourceError
            XCTAssertTrue(expectedPyroEventSourceError! == eventSourceError)
            
            switch eventSourceError {
            case .forcedClose:
                XCTAssertTrue(eventSource.state == .closed)
                XCTAssertNil(eventSource.session)
            default:
                break
            }
        
        } else if expectedRequestError != nil {
            XCTAssertTrue(error is RequestError)
            let requestError = error as! RequestError
            XCTAssertTrue(expectedRequestError! == requestError)
            XCTAssertTrue(eventSource.state == .closed)
            XCTAssertNil(eventSource.session)
        }
    }
    
    func pyroEventSource(_ eventSource: PyroEventSource, didReceiveMessage message: PyroEventSourceMessage) {
        XCTAssertTrue(eventSource == self.eventSource)
        
        if expectedMessage != nil {
            XCTAssertEqual(expectedMessage!.id, message.id)
            XCTAssertEqual(expectedMessage!.event, message.event)
            XCTAssertEqual(expectedMessage!.data, message.data)
        }
    }
    
    func pyroEventSourceOnOpen(_ eventSource: PyroEventSource) {
        XCTAssertTrue(eventSource == self.eventSource)
        XCTAssertTrue(eventSource.state == .open)
        
        isCalledOpenCallback = true
    }
    
    func pyroEventSourceOnClosed(_ eventSource: PyroEventSource) {
        XCTAssertTrue(eventSource == self.eventSource)
        XCTAssertTrue(eventSource.state == .closed)
        
        isCalledClosedCallback = true
    }
    
    func pyroEventSourceOnConnecting(_ eventSource: PyroEventSource) {
        XCTAssertTrue(eventSource == self.eventSource)
        XCTAssertTrue(eventSource.state == .connecting)
    
        isCalledConnectingCallback = true
    }
}
