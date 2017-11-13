//
//  PyroTransactionTemporaryPathTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 20/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PyroTransactionTemporaryPathTest: XCTestCase {
    
    func testCreate() {
        let tempPath = PyroTransactionTemporaryPath.create()
        XCTAssertEqual(tempPath.expiration, 30)
        XCTAssertEqual(tempPath.key, "pyrobase_transactions")
        XCTAssertTrue(tempPath.elapsedTime is Calendar)
        XCTAssertEqual(tempPath.elapsedTime as! Calendar, Calendar.current)
    }
    
    func testIsTransactionDateExpiredWithCorrectTimestamp() {
        let elapsedTime = PyroTransactionElapsedTimeMock()
        let expiration: UInt = 10
        let key: String = "key"
        let now = Date()
        let tempPath = PyroTransactionTemporaryPath(key: key, expiration: expiration, elapsedTime: elapsedTime)
        let _ = tempPath.isTransactionDateExpired(1000, now: now)
        XCTAssertEqual(elapsedTime.startDate.timeIntervalSince1970, 1)
    }
    
    func testIsTransactionDateExpiredShouldReturnTrue() {
        let elapsedTime = PyroTransactionElapsedTimeMock()
        let expiration: UInt = 10
        let key: String = "key"
        let now = Date()
        
        var tempPath = PyroTransactionTemporaryPath(key: key, expiration: expiration, elapsedTime: elapsedTime)
        
        elapsedTime.expectedSeconds = 10
        var isExpired = tempPath.isTransactionDateExpired(1000, now: now)
        XCTAssertTrue(isExpired)
        
        elapsedTime.expectedSeconds = 11
        isExpired = tempPath.isTransactionDateExpired(1000, now: now)
        XCTAssertTrue(isExpired)
        
        tempPath = PyroTransactionTemporaryPath.create()
        
        var components = DateComponents()
        components.second = Int(tempPath.expiration)
        var futureDate = Calendar.current.date(byAdding: components, to: now)!
        isExpired = tempPath.isTransactionDateExpired(futureDate.timeIntervalSince1970 * 1000, now: now)
        XCTAssertTrue(isExpired)
        
        components.second = Int(tempPath.expiration + 1)
        futureDate = Calendar.current.date(byAdding: components, to: now)!
        isExpired = tempPath.isTransactionDateExpired(futureDate.timeIntervalSince1970 * 1000, now: now)
        XCTAssertTrue(isExpired)
    }
    
    func testIsTransactionDateExpiredShouldReturnFalse() {
        let elapsedTime = PyroTransactionElapsedTimeMock()
        let expiration: UInt = 10
        let key: String = "key"
        let now = Date()
        
        var tempPath = PyroTransactionTemporaryPath(key: key, expiration: expiration, elapsedTime: elapsedTime)
        
        elapsedTime.expectedSeconds = 9
        var isExpired = tempPath.isTransactionDateExpired(1000, now: now)
        XCTAssertFalse(isExpired)
        
        elapsedTime.expectedSeconds = 0
        isExpired = tempPath.isTransactionDateExpired(1000, now: now)
        XCTAssertFalse(isExpired)
        
        tempPath = PyroTransactionTemporaryPath.create()
        
        var components = DateComponents()
        components.second = Int(tempPath.expiration) - 1
        var futureDate = Calendar.current.date(byAdding: components, to: now)!
        isExpired = tempPath.isTransactionDateExpired(futureDate.timeIntervalSince1970 * 1000, now: now)
        XCTAssertFalse(isExpired)
        
        components.second = 0
        futureDate = Calendar.current.date(byAdding: components, to: now)!
        isExpired = tempPath.isTransactionDateExpired(futureDate.timeIntervalSince1970 * 1000, now: now)
        XCTAssertFalse(isExpired)
    }
    
    func testIsTransactionDateExpiredWithNilElapsedSeconds() {
        let elapsedTime = PyroTransactionElapsedTimeMock()
        let expiration: UInt = 10
        let key: String = "key"
        let now = Date()
        let tempPath = PyroTransactionTemporaryPath(key: key, expiration: expiration, elapsedTime: elapsedTime)
        
        elapsedTime.expectedSeconds = nil
        let isExpired = tempPath.isTransactionDateExpired(1000, now: now)
        XCTAssertFalse(isExpired)
    }
}
