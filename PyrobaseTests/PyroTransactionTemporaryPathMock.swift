//
//  PyroTransactionTemporaryPathMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 19/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PyroTransactionTemporaryPathMock: PyroTransactionTemporaryPathProtocol {

    var key: String = ""
    var expiration: UInt = 0
    var isExpired: Bool = false
    
    func isTransactionDateExpired(_ timestamp: Double = 0) -> Bool {
        return isExpired
    }
}
