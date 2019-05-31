//
//  CCNetworkingTests.swift
//  CCNetworkingTests
//
//  Created by chai.chai on 2019/4/19.
//  Copyright © 2019 chai.chai. All rights reserved.
//

import XCTest
@testable import CCNetworking
import Network

class CCNetworkingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // https://itunes.apple.com/search?term=square&country=gb&media=software&limit=10
    func testGetRequest() {
        let params = ["term": "square",
                      "country": "gb",
                      "media": "software",
                      "limit": 10] as [String : AnyObject]
        Network.request(url: "", method: .get, params: params) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
        }
    }

    func testPostRequest() {
        let params = ["term": "square",
                      "country": "gb",
                      "media": "software",
                      "limit": 10] as [String : AnyObject]
        Network.request(url: "https://itunes.apple.com/search", method: .post, params: params) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
        }
    }
}
