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
    
    func isTransactionDateExpired(_ timestamp: Double) -> Bool
}

public class PyroTransactionTemporaryPath: PyroTransactionTemporaryPathProtocol {

    public var key: String
    public var expiration: UInt
    
    public class func create() -> PyroTransactionTemporaryPath {
        return PyroTransactionTemporaryPath(key: "pyrobase_transactions", expiration: 30)
    }
    
    public init(key: String, expiration: UInt) {
        self.key = key
        self.expiration = expiration
    }
    
    public func isTransactionDateExpired(_ timestamp: Double) -> Bool {
        let now = Date()
        let transactionDate = Date(timeIntervalSince1970: timestamp / 1000)
        let seconds: Int = Calendar.current.dateComponents([.second], from: transactionDate, to: now).second ?? 0
        
        return seconds < Int(expiration)
    }
}
