//
//  PyroTransactionTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 15/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroTransactionTest: XCTestCase {
    
    func testCreate() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let transaction = PyroTransaction.create(baseURL: baseURL, accessToken: accessToken)
        XCTAssertTrue(transaction.tempPath is PyroTransactionTemporaryPath)
        XCTAssertEqual(transaction.tempPath.key, "pyrobase_transactions")
        XCTAssertEqual(transaction.tempPath.expiration, 30)
        XCTAssertEqual(transaction.baseURL, baseURL)
        XCTAssertTrue(transaction.path is RequestPath)
        XCTAssertTrue(transaction.request is Request)
        XCTAssertEqual((transaction.path as! RequestPath).accessToken, accessToken)
        XCTAssertEqual((transaction.path as! RequestPath).baseURL, baseURL)
    }
    
    func testReadTransactionWithCorrectPath() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadTransaction")
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { _ in
            XCTAssertEqual(request.urlPath, "\(baseURL)/\(tempPath.key)/\(parentPath)/\(childKey).json?auth=\(accessToken)")
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testReadTransactionWithCustomError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadTransaction")
        
        request.expectedErrors.append(RequestError.invalidURL)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .succeeded:
                XCTFail()
            
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let errorInfo = info as! RequestError
                XCTAssertTrue(errorInfo == .invalidURL)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testReadTransactionWithInvalidExpirationTimestampError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPathMock()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadTransaction")
        
        request.expectedData.append("abcde12345qwert")
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is PyroTransactionError)
                let errorInfo = info as! PyroTransactionError
                XCTAssertTrue(errorInfo == .invalidExpirationTimestamp)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testReadTransactionWithActiveTransactionNotDoneError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPathMock()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadTransaction")
        
        request.expectedData.append("1234567890")
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is PyroTransactionError)
                let errorInfo = info as! PyroTransactionError
                XCTAssertTrue(errorInfo == .activeTransactionNotDone)
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testWriteTransactionWithCorrectRequestInfo() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testWriteTransaction")
        
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(RequestError.invalidURL)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { _ in
            XCTAssertEqual(request.urlPath, "\(baseURL)/\(tempPath.key).json?auth=\(accessToken)")
            XCTAssertEqual(request.writeData.count, 1)
            
            let key = "\(parentPath)/\(childKey)"
            XCTAssertNotNil(request.writeData[key])
            
            let value = request.writeData[key] as! [String: String]
            XCTAssertNotNil(value[".sv"])
            XCTAssertEqual(value[".sv"], "timestamp")
            
            XCTAssertTrue(request.requestMethod == .patch)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testWriteTransactionWithCustomError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testWriteTransaction")
        
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(RequestError.invalidURL)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let errorInfo = info as! RequestError
                XCTAssertTrue(errorInfo == .invalidURL)
            }
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testWriteTransactionShouldBeCalledWhenTransactionDateExpiredOnRead() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPathMock()
        let transaction = PyroTransactionMock(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadTransaction")
        
        tempPath.isExpired = true
        request.expectedData.append("1234567890")
        transaction.shouldProceedWriteTransaction = false
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testReadChildWithCorrectRequestInfo() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadChild")
        
        request.shouldURLPathBeReplaced = false
        request.shouldRequestMethodBeReplaced = false
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(RequestError.invalidURL)
        request.expectedData.append(true)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { _ in
            XCTAssertEqual(request.urlPath, "\(baseURL)/\(parentPath)/\(childKey).json?auth=\(accessToken)")
            XCTAssertTrue(request.requestMethod == .get)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testReadChildWithCustomError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransactionMock(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadChild")
        
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(RequestError.invalidURL)
        request.expectedData.append(true)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let errorInfo = info as! RequestError
                XCTAssertTrue(errorInfo == .invalidURL)
            }
            
            XCTAssertTrue(transaction.isDeleted)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }

    func testWriteChildShouldBeCalledWhenSucceededReadChild() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPathMock()
        let transaction = PyroTransactionMock(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testWriteChild")
        
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(nil)
        request.expectedData.append(true)
        request.expectedData.append(true)
        
        transaction.shouldProceedWriteChild = false
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }

    func testWriteChildWithCorrectRequestInfo() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadChild")
        
        request.shouldURLPathBeReplaced = false
        request.shouldRequestMethodBeReplaced = false
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(RequestError.invalidURL)
        request.expectedData.append(true)
        request.expectedData.append(1)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { _ in
            XCTAssertEqual(request.urlPath, "\(baseURL)/\(parentPath).json?auth=\(accessToken)")
            XCTAssertEqual(request.writeData.count, 1)
            
            let key = "\(childKey)"
            let expectedData: Int = mutator(1) as! Int
            
            XCTAssertNotNil(request.writeData[key])
            XCTAssertEqual(request.writeData[key] as! Int, expectedData)
            XCTAssertTrue(request.requestMethod == .patch)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testWriteChildWithCustomError() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransactionMock(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadChild")
        
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(RequestError.invalidURL)
        request.expectedData.append(true)
        request.expectedData.append(1)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .succeeded:
                XCTFail()
                
            case .failed(let info):
                XCTAssertTrue(info is RequestError)
                let errorInfo = info as! RequestError
                XCTAssertTrue(errorInfo == .invalidURL)
            }
            
            XCTAssertTrue(transaction.isDeleted)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testWriteChildWithSucceededResult() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransactionMock(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testReadChild")
        
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(nil)
        request.expectedData.append(true)
        request.expectedData.append(1)
        request.expectedData.append(["likes_count": mutator(1)])
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let info):
                XCTAssertTrue(info is [AnyHashable: Any])
                let resultInfo = info as! [AnyHashable: Any]
                let likesCount = resultInfo["likes_count"]
                XCTAssertTrue(likesCount is Int)
                XCTAssertEqual(likesCount as! Int, 2)
            }
            
            XCTAssertTrue(transaction.isDeleted)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testDeleteTransactionWithCorrectRequestInfo() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let request = RequestMock()
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let tempPath = PyroTransactionTemporaryPath.create()
        let transaction = PyroTransaction(request: request, path: path, tempPath: tempPath)
        let parentPath = "posts/abcde12345qwert"
        let childKey = "likes_count"
        let mutator: (Any) -> Any = { info in
            let count = info as! Int
            return count + 1
        }
        let expectation1 = expectation(description: "testDeleteTransaction")
        
        request.shouldURLPathBeReplaced = true
        request.shouldRequestMethodBeReplaced = true
        request.expectedErrors.append(RequestError.nullJSON)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(nil)
        request.expectedErrors.append(RequestError.invalidURL)
        request.expectedData.append(true)
        request.expectedData.append(1)
        request.expectedData.append(true)
        
        transaction.run(parentPath: parentPath, childKey: childKey, mutator: mutator) { result in
            XCTAssertEqual(request.urlPath, "\(baseURL)/\(tempPath.key)/\(parentPath).json?auth=\(accessToken)")
            XCTAssertTrue(request.requestMethod == .delete)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
}
