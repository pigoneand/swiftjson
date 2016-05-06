//
//  swiftjsonTests.swift
//  swiftjsonTests
//
//  Created by 朱 一和 on 16/5/6.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import XCTest

@testable import swiftjson

class swiftjsonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let (_, offset) = NilTokenGenerator("\n", offset: 0);
        
        XCTAssertEqual(offset, 1);
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
