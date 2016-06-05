//
//  swiftjsonTests.swift
//  swiftjsonTests
//
//  Created by 朱 一和 on 16/5/6.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import XCTest

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
        let (token, offset, _) = NilTokenGenerator("\n", offset: 0);
        XCTAssertEqual(offset, 1);
        XCTAssertEqual(JsonLexToken.BLANK, token!);
    }
    
    func testConstWordTokenGenerator() {
        let (token1, offset1, _) = ConstWordTokenGenerator("null", offset: 0);
        XCTAssertEqual(offset1, 4);
        XCTAssertEqual(JsonLexToken.NULL, token1!);
        
        let (_, offset2, _) = ConstWordTokenGenerator("{", offset: 0);
        XCTAssertEqual(offset2, 1);
        
    }
    
    func testStringTokenGenerator() {
        let (token1, offset1, _) = StringTokenGenerator("\"123\"", offset: 0);
        XCTAssertEqual(offset1, 5);
        XCTAssertEqual(JsonLexToken.STRING("123"), token1!);
    }
    
    func testNumberTokenGenerator() {
        let (token1, offset1, _) = NumberTokenGenerator("0", offset: 0);
        XCTAssertEqual(offset1, 1);
        XCTAssertEqual(JsonLexToken.NUMBER(0), token1!);
        
        let (token2, offset2, _) = NumberTokenGenerator("-1", offset: 0);
        XCTAssertEqual(offset2, 2);
        XCTAssertEqual(JsonLexToken.NUMBER(-1), token2!);
        
        let (token3, offset3, _) = NumberTokenGenerator("0.999", offset: 0);
        XCTAssertEqual(offset3, 5);
        XCTAssertEqual(JsonLexToken.NUMBER(0.999), token3!);
        
        let (token4, offset4, _) = NumberTokenGenerator("-10.999", offset: 0);
        XCTAssertEqual(offset4, 7);
        XCTAssertEqual(JsonLexToken.NUMBER(-10.999), token4!);
        
        let (token5, offset5, _) = NumberTokenGenerator("1e3", offset: 0);
        XCTAssertEqual(offset5, 3);
        XCTAssertEqual(JsonLexToken.NUMBER(1e3), token5!);
    }
    
    func testJsonLexer1() {
        let jsonLexer = JsonLexer();
        let (tokens, _) = jsonLexer.ParseJsonFromString("{}");
        XCTAssertEqual(2, tokens.count);
        XCTAssertEqual(JsonLexToken.BEGIN_OBJECT, tokens[0]);
        XCTAssertEqual(JsonLexToken.END_OBJECT, tokens[1]);
    }
    
    func testJsonLexer2() {
        let jsonLexer = JsonLexer();
        let (tokens, error) = jsonLexer.ParseJsonFromString("{\"name\": \"pigoneand\", \"age\": 23}");
        XCTAssertNil(error);
        XCTAssertTrue(tokens.contains(JsonLexToken.STRING("name")));
        XCTAssertTrue(tokens.contains(JsonLexToken.NUMBER(23)));
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
