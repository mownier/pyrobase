//
//  PlistReader.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

protocol PlistReaderContentProtocol {
    
    func extract(at path: String) -> Data?
}

protocol PlistReaderResourceProtocol {
    
    func path(for name: String) -> String?
}

enum PlistReaderError: Error {
    
    case notFound
    case noContent
    case unreadable
}

class PlistReader {
    
    internal(set) var data: Any!
    internal(set) var name: String
    
    init(name: String, resource: PlistReaderResourceProtocol, content: PlistReaderContentProtocol, format: PropertyListSerialization.PropertyListFormat, serialization: PropertyListSerialization.Type) throws {
        self.name = name
        
        guard let path = resource.path(for: name) else {
            throw PlistReaderError.notFound
        }
        
        guard let xml = content.extract(at: path) else {
            throw PlistReaderError.noContent
        }
        
        var plistFormat = format
        
        guard let data = try? serialization.propertyList(from: xml, options: [], format: &plistFormat) else {
            throw PlistReaderError.unreadable
        }
        
        self.data = data
    }
}

extension PlistReader {
    
    class func create(name: String, bundle: Bundle = .main, fileManager: FileManager = .default) -> PlistReader? {
        let format = PropertyListSerialization.PropertyListFormat.xml
        let serialization = PropertyListSerialization.self
        let reader = try? PlistReader(name: name, resource: bundle, content: fileManager, format: format, serialization: serialization)
        return reader
    }
}

extension Bundle: PlistReaderResourceProtocol {
    
    func path(for name: String) -> String? {
        return path(forResource: name, ofType: "plist")
    }
}

extension FileManager: PlistReaderContentProtocol {
    
    func extract(at path: String) -> Data? {
        return contents(atPath: path)
    }
}
