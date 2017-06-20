//
//  PyroTransactionParameter.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 16/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

struct Parameter {
    
    let parentPath: String
    let childKey: String
    let mutator: (Any) -> Any
    let completion: (PyroTransactionResult) -> Void
    
    init(parentPath: String, childKey: String, mutator: @escaping (Any) -> Any, completion: @escaping (PyroTransactionResult) -> Void) {
        self.parentPath = parentPath
        self.childKey = childKey
        self.mutator = mutator
        self.completion = completion
    }
}
