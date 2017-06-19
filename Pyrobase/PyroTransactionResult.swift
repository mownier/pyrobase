//
//  PyroTransactionResult.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 19/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public enum PyroTransactionResult {

    case failed(Error)
    case succeeded(Any)
}

public enum PyroTransactionError: Error {
    
    case invalidExpirationTimestamp
    case activeTransactionNotDone
}
