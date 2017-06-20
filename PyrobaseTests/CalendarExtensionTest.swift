//
//  CalendarExtensionTest.swift
//  Pyrobase
//
//  Created by Mounir Ybanez on 20/06/2017.
//  Copyright © 2017 Ner. All rights reserved.
//

import XCTest
@testable import Pyrobase

class CalendarExtensionTest: XCTestCase {
    
    func testElapsedSecondsComputation() {
        let now = Date()
        let calendar = Calendar.current

        var expectedSeconds = 2
        var components = DateComponents()
        components.second = expectedSeconds
        var fromDate = Calendar.current.date(byAdding: components, to: now)!
        var seconds = calendar.seconds(from: fromDate, to: now)
        XCTAssertEqual(expectedSeconds, seconds)
        
        expectedSeconds = -4
        components.second = expectedSeconds
        fromDate = Calendar.current.date(byAdding: components, to: now)!
        seconds = calendar.seconds(from: fromDate, to: now)
        XCTAssertEqual(expectedSeconds, seconds)
    }
}
