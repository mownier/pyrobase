//
//  RequestTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 02/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class RequestTest: XCTestCase {
    
    func testRead() {
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        request.read(path: "https://foo.firebaseio.com/users/12345/name.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let data):
                XCTAssertTrue(data is String)
                XCTAssertEqual(data as! String, "Luche")
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithInt() {
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        request.read(path: "https://foo.firebaseio.com/users/12345/int.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let data):
                XCTAssertTrue(data is String)
                let number = Int(data as! String)
                XCTAssertNotNil(number)
                XCTAssertEqual(number, 101)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithDouble() {
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let data):
                XCTAssertTrue(data is String)
                let number = Double(data as! String)
                XCTAssertNotNil(number)
                XCTAssertEqual(number, 101.12345)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithInvalidURL() {
        let request = Request.create()
        let expectation1 = expectation(description: "testRead")
        request.read(path: "", query: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
            
            case .failed(let error):
                XCTAssertTrue(error is RequestError)
                let errorInfo = error as! RequestError
                XCTAssertTrue(errorInfo == RequestError.invalidURL)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithError() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is URLSessionDataTaskMock.TaskMockError)
                let errorInfo = error as! URLSessionDataTaskMock.TaskMockError
                XCTAssertTrue(errorInfo == URLSessionDataTaskMock.TaskMockError.mockError1)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithNoURLResponse() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        
        taskResult.response = nil
        session.expectedDataTaskResult = taskResult
        
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is RequestError)
                let errorInfo = error as! RequestError
                XCTAssertTrue(errorInfo == RequestError.noURLResponse)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithNilData() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        
        taskResult.response = HTTPURLResponse()
        session.expectedDataTaskResult = taskResult
        
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let info):
                XCTAssertTrue(info is [AnyHashable: Any])
                let resultInfo = info as! [AnyHashable: Any]
                XCTAssertTrue(resultInfo.isEmpty)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithErrorParsingData() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = RequestOperationMock()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = Data(bytes: [1,2,3])
        session.expectedDataTaskResult = taskResult
        
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestOperationMock.MockError)
                let errorInfo = info as! RequestOperationMock.MockError
                XCTAssertTrue(errorInfo == RequestOperationMock.MockError.failedToParse)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReadWithJSONNull() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testRead")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = "null".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        request.read(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", query: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let resultInfo = info as! RequestError
                XCTAssertTrue(resultInfo == RequestError.nullJSON)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteWithInvalidURL() {
        let request = Request.create()
        let expectation1 = expectation(description: "testWrite")
        request.write(path: "", method: .post, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is RequestError)
                let errorInfo = error as! RequestError
                XCTAssertTrue(errorInfo == RequestError.invalidURL)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteWithError() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWrite")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .post, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is URLSessionDataTaskMock.TaskMockError)
                let errorInfo = error as! URLSessionDataTaskMock.TaskMockError
                XCTAssertTrue(errorInfo == URLSessionDataTaskMock.TaskMockError.mockError1)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteWithNoURLResponse() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWrite")
        
        taskResult.response = nil
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .post, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is RequestError)
                let errorInfo = error as! RequestError
                XCTAssertTrue(errorInfo == RequestError.noURLResponse)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteWithNilData() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWrite")
        
        taskResult.response = HTTPURLResponse()
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .post, data: [:]) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let info):
                XCTAssertTrue(info is [AnyHashable: Any])
                let resultInfo = info as! [AnyHashable: Any]
                XCTAssertTrue(resultInfo.isEmpty)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteWithErrorParsingData() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = RequestOperationMock()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWrite")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = Data(bytes: [1,2,3])
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .post, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestOperationMock.MockError)
                let errorInfo = info as! RequestOperationMock.MockError
                XCTAssertTrue(errorInfo == RequestOperationMock.MockError.failedToParse)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteWithInvalidURL() {
        let request = Request.create()
        let expectation1 = expectation(description: "testDelete")
        request.delete(path: "") { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is RequestError)
                let errorInfo = error as! RequestError
                XCTAssertTrue(errorInfo == RequestError.invalidURL)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteWithError() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testDelete")
        
        taskResult.error = URLSessionDataTaskMock.TaskMockError.mockError1
        session.expectedDataTaskResult = taskResult
        
        request.delete(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken") { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is URLSessionDataTaskMock.TaskMockError)
                let errorInfo = error as! URLSessionDataTaskMock.TaskMockError
                XCTAssertTrue(errorInfo == URLSessionDataTaskMock.TaskMockError.mockError1)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteWithNoURLResponse() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testDelete")
        
        taskResult.response = nil
        session.expectedDataTaskResult = taskResult
        
        request.delete(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken") { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let error):
                XCTAssertTrue(error is RequestError)
                let errorInfo = error as! RequestError
                XCTAssertTrue(errorInfo == RequestError.noURLResponse)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteNilData() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testDelete")
        
        taskResult.response = HTTPURLResponse()
        session.expectedDataTaskResult = taskResult
        
        request.delete(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken") { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let info):
                XCTAssertTrue(info is [AnyHashable: Any])
                let resultInfo = info as! [AnyHashable: Any]
                XCTAssertTrue(resultInfo.isEmpty)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteWithErrorParsingData() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = RequestOperationMock()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testDelete")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = Data(bytes: [1,2,3])
        session.expectedDataTaskResult = taskResult
        
        request.delete(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken") { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestOperationMock.MockError)
                let errorInfo = info as! RequestOperationMock.MockError
                XCTAssertTrue(errorInfo == RequestOperationMock.MockError.failedToParse)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteWithJSONNull() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testDelete")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = "null".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        request.delete(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken") { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let info):
                XCTAssertTrue(info is String)
                let resultInfo = info as! String
                XCTAssertEqual(resultInfo.lowercased(), "null")
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteHavingPOSTWithJSONNull() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWritePOST")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = "null".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .post, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let resultInfo = info as! RequestError
                XCTAssertTrue(resultInfo == RequestError.nullJSON)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteHavingPUTWithJSONNull() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWritePUT")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = "null".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .put, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let resultInfo = info as! RequestError
                XCTAssertTrue(resultInfo == RequestError.nullJSON)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWriteHavingPATCHWithJSONNull() {
        let taskResult = URLSessionDataTaskMock.Result()
        let session = URLSessionMock()
        let operation = JSONRequestOperation.create()
        let request = Request(session: session, operation: operation)
        let expectation1 = expectation(description: "testWritePATCH")
        
        taskResult.response = HTTPURLResponse()
        taskResult.data = "null".data(using: .utf8)
        session.expectedDataTaskResult = taskResult
        
        request.write(path: "https://foo.firebaseio.com/users/12345/double.json?access_token=accessToken", method: .patch, data: [:]) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let resultInfo = info as! RequestError
                XCTAssertTrue(resultInfo == RequestError.nullJSON)
            }
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
