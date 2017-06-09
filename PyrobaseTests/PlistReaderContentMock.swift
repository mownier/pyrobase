//
//  PlistReaderContentMock.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

@testable import Pyrobase

class PlistReaderContentMock: PlistReaderContentProtocol {

    var expectedData: Data?
    
    func extract(at path: String) -> Data? {
        return expectedData
    }
}
