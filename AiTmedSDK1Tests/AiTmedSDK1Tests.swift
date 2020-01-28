//
//  AiTmedSDK1Tests.swift
//  AiTmedSDK1Tests
//
//  Created by Yi Tong on 1/27/20.
//  Copyright © 2020 Yi Tong. All rights reserved.
//

import XCTest
@testable import AiTmedSDK1

class AiTmedSDK1Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testZipAndUnzip() {
        let data1 = "Hello, world!".data(using: .utf8)!
        let data2 = "".data(using: .utf8)!
        let data3 = "1".data(using: .utf8)!
        let data4 = "a".data(using: .utf8)!
        let data5 = "         ".data(using: .utf8)!
        
        assert(data1 == (try! data1.zip().unzip()))
        assert(data2 == (try! data2.zip().unzip()))
        assert(data3 == (try! data3.zip().unzip()))
        assert(data4 == (try! data4.zip().unzip()))
        assert(data5 == (try! data5.zip().unzip()))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
