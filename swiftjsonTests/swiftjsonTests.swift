//
//  swiftjsonTests.swift
//  swiftjsonTests
//
//  Created by 朱 一和 on 16/5/6.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import XCTest

@testable import swiftjson

extension JsonLexToken : Equatable {}

func ==(lhs: JsonLexToken, rhs: JsonLexToken) -> Bool {
    switch (lhs, rhs) {
    case (let .NUMBER(n1), let .NUMBER(n2)):
        return n1 == n2;
        
    case (let .STRING(s1), let .STRING(s2)):
        return s1 == s2
        
    case (.TRUE, .TRUE):
        return true
    case (.FALSE, .FALSE):
        return true
    case (.NULL, .NULL):
        return true
        
    default:
        return false
    }
}

class JsonLexerTestCase : XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNilTokenGenerator() {
        let (token, offset) = NilTokenGenerator("\n", offset: 0);
        XCTAssertEqual(offset, 1);
        XCTAssertNil(token);
    }
    
    func testConstWordTokenGenerator() {
        let (token1, offset1) = ConstWordTokenGenerator("null", offset: 0);
        XCTAssertEqual(offset1, 4);
        XCTAssertEqual(JsonLexToken.NULL, (token1!));
        
        let (_, offset2) = ConstWordTokenGenerator("{", offset: 0);
        XCTAssertEqual(offset2, 1);
        
    }
    
    func testStringTokenGenerator() {
        let (token1, offset1) = StringTokenGenerator("\"123\"", offset: 0);
        XCTAssertEqual(offset1, 5);
        XCTAssertEqual(JsonLexToken.STRING("123"), token1);
    }
    
    func testNumberTokenGenerator() {
        let (token1, offset1) = NumberTokenGenerator("0", offset: 0);
        XCTAssertEqual(offset1, 1);
        XCTAssertEqual(JsonLexToken.NUMBER(0), token1);
        
        let (token2, offset2) = NumberTokenGenerator("-1", offset: 0);
        XCTAssertEqual(offset2, 2);
        XCTAssertEqual(JsonLexToken.NUMBER(-1), token2);
        
        let (token3, offset3) = NumberTokenGenerator("0.999", offset: 0);
        XCTAssertEqual(offset3, 5);
        XCTAssertEqual(JsonLexToken.NUMBER(0.999), token3);
        
        let (token4, offset4) = NumberTokenGenerator("-10.999", offset: 0);
        XCTAssertEqual(offset4, 7);
        XCTAssertEqual(JsonLexToken.NUMBER(-10.999), token4);

        let (token5, offset5) = NumberTokenGenerator("1e3", offset: 0);
        XCTAssertEqual(offset5, 3);
        XCTAssertEqual(JsonLexToken.NUMBER(1e3), token5);
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
