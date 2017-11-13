//
//  PlistReaderTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 09/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class PlistReaderTest: XCTestCase {
    
    func testInitWithErrorNotFound() {
        let resource = PlistReaderResourceMock()
        let content = PlistReaderContentMock()
        let format = PropertyListSerialization.PropertyListFormat.xml
        let serialization = PropertyListSerialization.self
        let isSucceeded: Bool
        
        resource.expectedPath = nil
        
        do {
            let _ = try PlistReader(name: "", resource: resource, content: content, format: format, serialization: serialization)
            isSucceeded = false
            
        } catch PlistReaderError.notFound {
            isSucceeded = true
        
        } catch {
            isSucceeded = false
        }
        
        XCTAssertTrue(isSucceeded)
    }
    
    func testInitWithErrorNoContent() {
        let resource = PlistReaderResourceMock()
        let content = PlistReaderContentMock()
        let format = PropertyListSerialization.PropertyListFormat.xml
        let serialization = PropertyListSerialization.self
        let isSucceeded: Bool
        
        resource.expectedPath = "path"
        content.expectedData = nil
        
        do {
            let _ = try PlistReader(name: "", resource: resource, content: content, format: format, serialization: serialization)
            isSucceeded = false
            
        } catch PlistReaderError.noContent {
            isSucceeded = true
            
        } catch {
            isSucceeded = false
        }
        
        XCTAssertTrue(isSucceeded)
    }
    
    func testInitWithErrorUnreadable() {
        let resource = PlistReaderResourceMock()
        let content = PlistReaderContentMock()
        let format = PropertyListSerialization.PropertyListFormat.xml
        let serialization = PlistSerializationMock.self
        let isSucceeded: Bool
        
        resource.expectedPath = "path"
        content.expectedData = Data(bytes: [1,2,3])
        serialization.expectedInfo = nil
        
        do {
            let _ = try PlistReader(name: "", resource: resource, content: content, format: format, serialization: serialization)
            isSucceeded = false
            
        } catch PlistReaderError.unreadable {
            isSucceeded = true
            
        } catch {
            isSucceeded = false
        }
        
        XCTAssertTrue(isSucceeded)
    }
    
    func testInitWithNoErrors() {
        let resource = PlistReaderResourceMock()
        let content = PlistReaderContentMock()
        let format = PropertyListSerialization.PropertyListFormat.xml
        let serialization = PlistSerializationMock.self
        let isSucceeded: Bool
        
        resource.expectedPath = "path"
        content.expectedData = Data(bytes: [1,2,3])
        serialization.expectedInfo = ["name": "Nina"]
        
        do {
            let reader = try PlistReader(name: "", resource: resource, content: content, format: format, serialization: serialization)
            XCTAssertNotNil(reader.data)
            XCTAssertTrue(reader.data is [String: String])
            let readerInfo = reader.data as! [String: String]
            XCTAssertEqual(readerInfo.count, 1)
            XCTAssertEqual(readerInfo["name"], "Nina")
            isSucceeded = true
            
        } catch {
            isSucceeded = false
        }
        
        XCTAssertTrue(isSucceeded)
    }
    
    func testCreate() {
        let bundle = Bundle(for: type(of: self))
        var reader = PlistReader.create(name: "PlistReaderSample", bundle: bundle)
        XCTAssertNotNil(reader)
        
        reader = PlistReader.create(name: "PlistReader-NonExisting")
        XCTAssertNil(reader)
    }
}
