//
//  PyroAuthTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroAuthTest: XCTestCase {
    
    func testCreate() {
        let key: String = "api_key"
        
        var auth = PyroAuth.create(key: key)
        XCTAssertNil(auth) // This is nil because Bundle.main's path is different when testing
        
        let bundle: Bundle = Bundle(for: type(of: self))
        auth = PyroAuth.create(key: key, bundle: bundle)
        XCTAssertNotNil(auth)
        XCTAssertEqual(auth!.registerPath, "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser")
        XCTAssertEqual(auth!.signInPath, "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword")
        
        auth = PyroAuth.create(key: key, bundle: bundle, plistName: "PlistReaderSample")
        XCTAssertTrue(auth!.signInPath.isEmpty)
        XCTAssertTrue(auth!.registerPath.isEmpty)
    }
    
    func testRegisterBeforeRequestIsTriggered() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let request = AuthRequestMock()
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let expectation1 = expectation(description: "testRegister")
        
        auth.register(email: email, password: password) { _ in
            let expectedWriteData: [AnyHashable: Any] = [
                "email": email,
                "password": password,
                "returnSecureToken": true
            ]
            
            let expectedWriteURLPath: String = "\(auth.registerPath)?key=\(apiKey)"
            let expectedMethod: RequestMethod = .post
            
            XCTAssertEqual(expectedWriteData.count, request.writeData.count)
            XCTAssertEqual(expectedWriteData["email"] as! String, request.writeData["email"] as! String)
            XCTAssertEqual(expectedWriteData["password"] as! String, request.writeData["password"] as! String)
            XCTAssertEqual(expectedWriteData["returnSecureToken"] as! Bool, request.writeData["returnSecureToken"] as! Bool)
            XCTAssertEqual(expectedWriteURLPath, request.writeURLPath)
            XCTAssertTrue(expectedMethod == request.writeMethod)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRegisterWithNoError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRegister")
        let expectedContent = [
            "email": email,
            "idToken": "poiuy1820ghjfk",
            "localId": "userId12345",
            "refreshToken": "qwert8907zxcv",
            "expiresIn": "3600"
        ]
        
        taskResult.response = URLResponse()
        taskResult.data = try? JSONSerialization.data(withJSONObject: expectedContent, options: [])
        session.expectedDataTaskResult = taskResult
        
        auth.register(email: email, password: password) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let content):
                XCTAssertFalse(content.userId.isEmpty)
                XCTAssertFalse(content.email.isEmpty)
                XCTAssertFalse(content.accessToken.isEmpty)
                XCTAssertFalse(content.refreshToken.isEmpty)
                XCTAssertFalse(content.expiration.isEmpty)
                
                XCTAssertEqual(content.userId, expectedContent["localId"])
                XCTAssertEqual(content.email, expectedContent["email"])
                XCTAssertEqual(content.accessToken, expectedContent["idToken"])
                XCTAssertEqual(content.refreshToken, expectedContent["refreshToken"])
                XCTAssertEqual(content.expiration, expectedContent["expiresIn"])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRegisterWithUnexpectedContentError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRegister")
        
        taskResult.response = URLResponse()
        taskResult.data = "success".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        auth.register(email: email, password: password) { result in
            switch result {
            case .succeeded:
                XCTFail()
            
            case .failed(let info):
                XCTAssertTrue(info is PyroAuthError)
                let errorInfo = info as! PyroAuthError
                XCTAssertTrue(errorInfo == PyroAuthError.unexpectedContent)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRegisterWithIncompleteContentError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRegister")
        let expectedContent = [
            "email": email,
            "idToken": "poiuy1820ghjfk",
        ]
        
        taskResult.response = URLResponse()
        taskResult.data = try? JSONSerialization.data(withJSONObject: expectedContent, options: [])
        session.expectedDataTaskResult = taskResult
        
        auth.register(email: email, password: password) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is PyroAuthError)
                let errorInfo = info as! PyroAuthError
                XCTAssertTrue(errorInfo == PyroAuthError.incompleteContent)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRegisterWithCustomError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRegister")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        auth.register(email: email, password: password) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is URLSessionDataTaskMock.TaskMockError)
                let errorInfo = info as! URLSessionDataTaskMock.TaskMockError
                XCTAssertTrue(errorInfo == URLSessionDataTaskMock.TaskMockError.mockError1)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSignInBeforeRequestIsTriggered() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let request = AuthRequestMock()
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let expectation1 = expectation(description: "testSignIn")
        
        auth.signIn(email: email, password: password) { _ in
            let expectedWriteData: [AnyHashable: Any] = [
                "email": email,
                "password": password,
                "returnSecureToken": true
            ]
            
            let expectedWriteURLPath: String = "\(auth.signInPath)?key=\(apiKey)"
            let expectedMethod: RequestMethod = .post
            
            XCTAssertEqual(expectedWriteData.count, request.writeData.count)
            XCTAssertEqual(expectedWriteData["email"] as! String, request.writeData["email"] as! String)
            XCTAssertEqual(expectedWriteData["password"] as! String, request.writeData["password"] as! String)
            XCTAssertEqual(expectedWriteData["returnSecureToken"] as! Bool, request.writeData["returnSecureToken"] as! Bool)
            XCTAssertEqual(expectedWriteURLPath, request.writeURLPath)
            XCTAssertTrue(expectedMethod == request.writeMethod)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSignInWithNoError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testSignIn")
        let expectedContent = [
            "email": email,
            "idToken": "poiuy1820ghjfk",
            "localId": "userId12345",
            "refreshToken": "qwert8907zxcv",
            "expiresIn": "3600"
        ]
        
        taskResult.response = URLResponse()
        taskResult.data = try? JSONSerialization.data(withJSONObject: expectedContent, options: [])
        session.expectedDataTaskResult = taskResult
        
        auth.signIn(email: email, password: password) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let content):
                XCTAssertFalse(content.userId.isEmpty)
                XCTAssertFalse(content.email.isEmpty)
                XCTAssertFalse(content.accessToken.isEmpty)
                XCTAssertFalse(content.refreshToken.isEmpty)
                XCTAssertFalse(content.expiration.isEmpty)
                
                XCTAssertEqual(content.userId, expectedContent["localId"])
                XCTAssertEqual(content.email, expectedContent["email"])
                XCTAssertEqual(content.accessToken, expectedContent["idToken"])
                XCTAssertEqual(content.refreshToken, expectedContent["refreshToken"])
                XCTAssertEqual(content.expiration, expectedContent["expiresIn"])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSignInWithUnexpectedContentError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testSignIn")
        
        taskResult.response = URLResponse()
        taskResult.data = "success".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        auth.signIn(email: email, password: password) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is PyroAuthError)
                let errorInfo = info as! PyroAuthError
                XCTAssertTrue(errorInfo == PyroAuthError.unexpectedContent)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSignInWithIncompleteContentError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testSignIn")
        let expectedContent = [
            "email": email,
            "idToken": "poiuy1820ghjfk",
            ]
        
        taskResult.response = URLResponse()
        taskResult.data = try? JSONSerialization.data(withJSONObject: expectedContent, options: [])
        session.expectedDataTaskResult = taskResult
        
        auth.signIn(email: email, password: password) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is PyroAuthError)
                let errorInfo = info as! PyroAuthError
                XCTAssertTrue(errorInfo == PyroAuthError.incompleteContent)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSignInWithCustomError() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let bundle: Bundle = Bundle(for: type(of: self))
        let auth = PyroAuth.create(key: apiKey, bundle: bundle, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testSignIn")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        auth.signIn(email: email, password: password) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is URLSessionDataTaskMock.TaskMockError)
                let errorInfo = info as! URLSessionDataTaskMock.TaskMockError
                XCTAssertTrue(errorInfo == URLSessionDataTaskMock.TaskMockError.mockError1)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}
