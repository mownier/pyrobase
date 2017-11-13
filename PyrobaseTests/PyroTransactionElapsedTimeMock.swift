//
//  PyroTransactionElapsedTimeMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 20/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PyroTransactionElapsedTimeMock: PyroTransactionElapsedTimeProtocol {

    var startDate: Date = Date()
    var nowDate: Date = Date()
    
    var expectedSeconds: Int? = 0
    
    func seconds(from transactionDate: Date, to now: Date) -> Int? {
        startDate = transactionDate
        nowDate = now
        return expectedSeconds
    }
}
