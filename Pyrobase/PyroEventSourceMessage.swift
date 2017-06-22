//
//  PyroEventSourceMessage.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 22/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public struct PyroEventSourceMessage {
    
    public var id: String
    public var event: String
    public var data: String
    
    public init() {
        self.id = ""
        self.event = ""
        self.data = ""
    }
}

extension PyroEventSourceMessage: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "\nid: \(id)\nevent: \(event)\ndata: \(data)\n"
    }
}
