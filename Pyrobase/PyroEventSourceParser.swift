//
//  PyroEventSourceParser.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 22/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

public protocol PyroEventSourceParserProtocol {
    
    func parse(_ data: Data) -> PyroEventSourceMessage
}

public class PyroEventSourceParser: PyroEventSourceParserProtocol {
    
    public func parse(_ data: Data) -> PyroEventSourceMessage {
        var message = PyroEventSourceMessage()
        
        guard let string = String(data: data, encoding: .utf8) else {
            return message
        }
        
        for event in string.components(separatedBy: CharacterSet.newlines) {
            guard !event.isEmpty && !event.hasPrefix(":") && !event.contains("retry:") else {
                continue
            }
            
            for line in event.components(separatedBy: CharacterSet.newlines) {
                guard let colonRange = line.range(of: ":") else {
                    continue
                }
                
                let keyRange = Range<String.Index>(uncheckedBounds: (line.startIndex, colonRange.lowerBound))
                let key = line.substring(with: keyRange).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                let valueRange = Range<String.Index>(uncheckedBounds: (line.index(after: colonRange.lowerBound), line.endIndex))
                let value = line.substring(with: valueRange).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                switch key.lowercased() {
                case "id":
                    message.id = value
                    
                case "event":
                    message.event = value
                    
                case "data":
                    message.data = value
                    
                default: break
                }
            }
        }
        
        return message
    }
}
