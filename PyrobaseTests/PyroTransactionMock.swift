//
//  PyroTransactionMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 20/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PyroTransactionMock: PyroTransaction {

    var shouldProceedWriteTransaction: Bool = true
    var shouldProceedReadChild: Bool = true
    var shouldProceedWriteChild: Bool = true
    var isDeleted: Bool = false
    
    var expectedSucceededInfo: Any?
    
    override func writeTransaction(param: Parameter) {
        guard !shouldProceedWriteTransaction else {
            super.writeTransaction(param: param)
            return
        }
        
        invokeCompletion(param)
    }
    
    override func readChild(param: Parameter) {
        guard !shouldProceedReadChild else {
            super.readChild(param: param)
            return
        }
        
        invokeCompletion(param)
    }
    
    override func writeChild(param: Parameter, info: Any) {
        guard !shouldProceedWriteChild else {
            super.writeChild(param: param, info: info)
            return
        }
        
        invokeCompletion(param)
    }
    
    override func deleteTransaction(param: Parameter, completion: @escaping (RequestResult) -> Void) {
        isDeleted = true
        completion(.succeeded(true))
    }
    
    func invokeCompletion(_ param: Parameter) {
        guard expectedSucceededInfo != nil else {
            param.completion(.succeeded(true))
            return
        }
        
        param.completion(.succeeded(expectedSucceededInfo!))
    }
}
