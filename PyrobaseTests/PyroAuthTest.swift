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
        
        var bundle: Bundle = .main
        var bundleIdentifier: String = bundle.bundleIdentifier ?? ""
        var auth = PyroAuth.create(key: key, bundleIdentifier: bundleIdentifier)
        XCTAssertNil(auth) // This is nil because Bundle.main's path is different when testing
        
        auth = PyroAuth.create(key: key)
        XCTAssertNotNil(auth)
        XCTAssertEqual(auth!.registerPath, "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser")
        XCTAssertEqual(auth!.signInPath, "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword")
        XCTAssertEqual(auth!.refreshPath, "https://securetoken.googleapis.com/v1/token")
        XCTAssertEqual(auth!.confirmationCodePath, "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getOobConfirmationCode")
        
        bundle = Bundle(for: type(of: self))
        bundleIdentifier = bundle.bundleIdentifier ?? ""
        auth = PyroAuth.create(key: key, bundleIdentifier: bundleIdentifier, plistName: "PlistReaderSample")
        XCTAssertTrue(auth!.signInPath.isEmpty)
        XCTAssertTrue(auth!.registerPath.isEmpty)
        XCTAssertTrue(auth!.refreshPath.isEmpty)
        XCTAssertTrue(auth!.confirmationCodePath.isEmpty)
        
        auth = PyroAuth.create(key: key, bundleIdentifier: bundleIdentifier, plistName: "Plist-NonExisting")
        XCTAssertNil(auth)
        
        auth = PyroAuthMock.create(key: key)
        XCTAssertNotNil(auth)
        XCTAssertTrue(PyroAuthMock.defaultRequest is Request)
        XCTAssertEqual(PyroAuthMock.defaultPlistName, "PyroAuthInfo")
        XCTAssertEqual(PyroAuthMock.defaultBundleIdentifier, "com.ner.Pyrobase")
    }
    
    func testRegisterBeforeRequestIsTriggered() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        let password: String = "12345"
        
        let request = AuthRequestMock()
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
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
    
    func testRefreshBeforeRequestIsTriggered() {
        let apiKey = "api_key"
        let refreshToken: String = "refresh_token"
        
        let request = AuthRequestMock()
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let expectation1 = expectation(description: "testRefresh")
        
        auth.refresh(token: refreshToken) { _ in
            let expectedWriteData: [AnyHashable: Any] = [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
            
            let expectedWriteURLPath: String = "\(auth.refreshPath)?key=\(apiKey)"
            let expectedMethod: RequestMethod = .post
            
            XCTAssertEqual(expectedWriteData.count, request.writeData.count)
            XCTAssertEqual(expectedWriteData["grant_type"] as! String, request.writeData["grant_type"] as! String)
            XCTAssertEqual(expectedWriteData["refresh_token"] as! String, request.writeData["refresh_token"] as! String)
            XCTAssertEqual(expectedWriteURLPath, request.writeURLPath)
            XCTAssertTrue(expectedMethod == request.writeMethod)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRefreshWithNoError() {
        let apiKey = "api_key"
        let refreshToken = "refresh_token"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRefresh")
        let expectedContent = [
            "access_token": "poiuy1820ghjfk",
            "refresh_token": "qwert8907zxcv",
            "expires_in": "3600"
        ]
        
        taskResult.response = URLResponse()
        taskResult.data = try? JSONSerialization.data(withJSONObject: expectedContent, options: [])
        session.expectedDataTaskResult = taskResult
        
        auth.refresh(token: refreshToken) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let content):
                XCTAssertFalse(content.accessToken.isEmpty)
                XCTAssertFalse(content.refreshToken.isEmpty)
                XCTAssertFalse(content.expiration.isEmpty)
                
                XCTAssertEqual(content.accessToken, expectedContent["access_token"])
                XCTAssertEqual(content.refreshToken, expectedContent["refresh_token"])
                XCTAssertEqual(content.expiration, expectedContent["expires_in"])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testRefreshWithUnexpectedContentError() {
        let apiKey = "api_key"
        let refreshToken = "refresh_token"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRefresh")
        
        taskResult.response = URLResponse()
        taskResult.data = "success".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        auth.refresh(token: refreshToken) { result in
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
    
    func testRefreshWithIncompleteContentError() {
        let apiKey = "api_key"
        let refreshToken = "refresh_token"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRefresh")
        let expectedContent = [
            "access_token": "poiuy1820ghjfk",
            ]
        
        taskResult.response = URLResponse()
        taskResult.data = try? JSONSerialization.data(withJSONObject: expectedContent, options: [])
        session.expectedDataTaskResult = taskResult
        
        auth.refresh(token: refreshToken) { result in
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
    
    func testRefreshWithCustomError() {
        let apiKey = "api_key"
        let refreshToken = "refresh_token"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testRefresh")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        auth.refresh(token: refreshToken) { result in
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
    
    func testSendPasswordResetBeforeRequestIsTriggered() {
        let apiKey = "api_key"
        let email: String = "me@me.com"
        
        let request = AuthRequestMock()
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let expectation1 = expectation(description: "testSendPasswordReset")
        
        auth.sendPasswordReset(email: email) { _ in
            let expectedWriteData: [AnyHashable: Any] = [
                "email": email,
                "requestType": "PASSWORD_RESET"
            ]
            
            let expectedWriteURLPath: String = "\(auth.confirmationCodePath)?key=\(apiKey)"
            let expectedMethod: RequestMethod = .post
            
            XCTAssertEqual(expectedWriteData.count, request.writeData.count)
            XCTAssertEqual(expectedWriteData["email"] as! String, request.writeData["email"] as! String)
            XCTAssertEqual(expectedWriteData["requestType"] as! String, request.writeData["requestType"] as! String)
            XCTAssertEqual(expectedWriteURLPath, request.writeURLPath)
            XCTAssertTrue(expectedMethod == request.writeMethod)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSendPasswordResetWithNoError() {
        let apiKey = "api_key"
        let email = "me@me.com"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testSendPasswordReset")
        
        taskResult.response = URLResponse()
        taskResult.data = Data(bytes: [1,2,3])
        session.expectedDataTaskResult = taskResult
        
        auth.sendPasswordReset(email: email) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let isSuccess):
                XCTAssertTrue(isSuccess)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testSendPasswordResetWithCustomError() {
        let apiKey = "api_key"
        let email = "me@me.com"
        
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let response = RequestResponse()
        let request = Request(session: session, operation: operation, response: response)
        let auth = PyroAuth.create(key: apiKey, request: request)!
        
        let taskResult = URLSessionDataTaskMock.Result()
        let expectation1 = expectation(description: "testSendPasswordReset")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        auth.sendPasswordReset(email: email) { result in
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
