//
//  PyrobaseTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 01/05/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyrobaseTest: XCTestCase {
    
    func testInitialization() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = Request.create()
        let pyrobase = Pyrobase(request: request, path: path)
        
        XCTAssertNotNil(pyrobase.path)
        XCTAssertNotNil(pyrobase.request)
    }
    
    func testCreate() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let pyrobase = Pyrobase.create(baseURL: baseURL, accessToken: accessToken)
        
        XCTAssertNotNil(pyrobase.path)
        XCTAssertTrue(pyrobase.path is RequestPath)
    }
    
    func testGet() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(request: request, path: path)
        
        let expectation1 = expectation(description: "testGet")
        pyrobase.get(path: "name", query: [:]) { result in
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
    
    func testPut() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(request: request, path: path)
        let expectedValue = ["last_name": "Valdez"]
        let expectation1 = expectation(description: "testPut")
        
        pyrobase.put(path: "name", value: expectedValue) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let data):
                XCTAssertTrue(data is [String: String])
                let resultInfo = data as! [String: String]
                XCTAssertEqual(resultInfo.count, expectedValue.count)
                XCTAssertEqual(resultInfo["last_name"], expectedValue["last_name"])
                
                let absolutePath = path.build("name")
                let content = request.content[absolutePath]
                XCTAssertTrue(content is [String: String])
                let contentInfo = content as! [String: String]
                XCTAssertEqual(contentInfo.count, expectedValue.count)
                XCTAssertEqual(contentInfo["last_name"], expectedValue["last_name"])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testPost() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(request: request, path: path)
        let expectedValue = ["message": "Hello world!"]
        let expectation1 = expectation(description: "testPost")
        
        pyrobase.post(path: "messages", value: expectedValue) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let data):
                XCTAssertTrue(data is [String: String])
                let resultInfo = data as! [String: String]
                XCTAssertEqual(resultInfo.count, 1)
                XCTAssertNotNil(resultInfo["name"])
                
                let content = request.content[resultInfo["name"]!]
                XCTAssertTrue(content is [String: String])
                let contentInfo = content as! [String: String]
                XCTAssertEqual(contentInfo.count, expectedValue.count)
                XCTAssertEqual(contentInfo["message"], expectedValue["message"])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testPatch() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(request: request, path: path)
        let expectedValue = ["date": "June 8, 2017"]
        let expectation1 = expectation(description: "testPost")
        
        pyrobase.patch(path: "messages/abcde12345qwert", value: expectedValue) { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let data):
                XCTAssertTrue(data is [String: String])
                let resultInfo = data as! [String: String]
                XCTAssertEqual(resultInfo.count, expectedValue.count)
                XCTAssertEqual(resultInfo["date"], expectedValue["date"])
                
                let absolutePath = path.build("messages/abcde12345qwert")
                let content = request.content[absolutePath]
                XCTAssertTrue(content is [String: String])
                let contentInfo = content as! [String: String]
                XCTAssertEqual(contentInfo.count, 2)
                XCTAssertEqual(contentInfo["message"], "Hello World!")
                XCTAssertEqual(contentInfo["date"], expectedValue["date"])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(request: request, path: path)
        let expectation1 = expectation(description: "testDelete")
        
        pyrobase.delete(path: "name") { result in
            switch result {
            case .failed:
                XCTFail()
                
            case .succeeded(let info):
                XCTAssertTrue(info is String)
                let resultInfo = info as! String
                XCTAssertEqual(resultInfo.lowercased(), "null")
                
                let absolutePath = path.build("name")
                XCTAssertNil(request.content[absolutePath])
            }
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testGetBaseURL() {
        let baseURL = "https://foo.firebaseio.com"
        let accessToken = "accessToken"
        let path = RequestPath(baseURL: baseURL, accessToken: accessToken)
        let request = RequestMock()
        let pyrobase = Pyrobase(request: request, path: path)
        
        XCTAssertEqual(pyrobase.baseURL, baseURL)
    }
}
