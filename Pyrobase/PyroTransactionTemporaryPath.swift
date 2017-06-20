//
//  PyroTransactionTemporaryPath.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 19/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol PyroTransactionTemporaryPathProtocol {
    
    var key: String { get }
    var expiration: UInt { get }
    
    func isTransactionDateExpired(_ timestamp: Double, now: Date) -> Bool
}

public class PyroTransactionTemporaryPath: PyroTransactionTemporaryPathProtocol {

    internal var elapsedTime: PyroTransactionElapsedTimeProtocol
    
    internal(set) public var key: String
    internal(set) public var expiration: UInt
    
    public class func create() -> PyroTransactionTemporaryPath {
        let key: String = "pyrobase_transactions"
        let expiration: UInt = 30
        let elapsedTime: Calendar = .current
        return PyroTransactionTemporaryPath(key: key, expiration: expiration, elapsedTime: elapsedTime)
    }
    
    public init(key: String, expiration: UInt, elapsedTime: PyroTransactionElapsedTimeProtocol) {
        self.key = key
        self.expiration = expiration
        self.elapsedTime = elapsedTime
    }
    
    public func isTransactionDateExpired(_ timestamp: Double, now: Date) -> Bool {
        let transactionDate = Date(timeIntervalSince1970: timestamp / 1000)
        
        guard let seconds: Int = elapsedTime.seconds(from: transactionDate, to: now) else {
            return false
        }
        
        return seconds >= Int(expiration)
    }
}

public protocol PyroTransactionElapsedTimeProtocol {
    
    func seconds(from: Date, to: Date) -> Int?
}

extension Calendar: PyroTransactionElapsedTimeProtocol {
    
    public func seconds(from transactionDate: Date, to now: Date) -> Int? {
        return dateComponents([.second], from: now, to: transactionDate).second
    }
}
