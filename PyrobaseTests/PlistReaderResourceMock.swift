//
//  BundleMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PlistReaderResourceMock: PlistReaderResourceProtocol {
    
    var expectedPath: String?
    
    func path(for name: String) -> String? {
        return expectedPath
    }
}
