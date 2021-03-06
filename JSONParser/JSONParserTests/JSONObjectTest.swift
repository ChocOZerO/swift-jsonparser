//
//  JSONObjectTest.swift
//  JSONParserTests
//
//  Created by TaeHyeonLee on 2017. 11. 21..
//  Copyright © 2017년 JK. All rights reserved.
//

import XCTest

@testable import JSONParser

class JSONObjectTest: XCTestCase {
    var jsonObject: JSONObject!

    override func setUp() {
        super.setUp()
        jsonObject = JSONObject()
    }

    override func tearDown() {
        jsonObject = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertNotNil(jsonObject)
    }

    func testAdd() {
        jsonObject.add(key: "jake", value: 3)
        XCTAssertEqual(jsonObject.count, 1)


        jsonObject.add(key: "jk", value: 5)
        XCTAssertEqual(jsonObject.count, 2)
    }

}
