//
//  ShawshankMatchTests.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import XCTest
@testable import Shawshank

class ShawshankMatchTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        Shawshank.release()
        super.tearDown()
    }

    func testURLRequestTestComponentPredicate() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLRequestTest.scheme("http").componentPredicate(components))
        XCTAssertFalse(URLRequestTest.scheme("https").componentPredicate(components))

        XCTAssertTrue(URLRequestTest.host("www.example.com").componentPredicate(components))
        XCTAssertFalse(URLRequestTest.host("example.com").componentPredicate(components))

        XCTAssertTrue(URLRequestTest.port(82).componentPredicate(components))
        XCTAssertFalse(URLRequestTest.port(80).componentPredicate(components))

        XCTAssertTrue(URLRequestTest.url(URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!).componentPredicate(components))
        XCTAssertFalse(URLRequestTest.url(URL(string: "http://www.example.com:80/path/to/something")!).componentPredicate(components))

        XCTAssertTrue(URLRequestTest.absolute("http://www.example.com:82/path/to/something?offset=10&count=100").componentPredicate(components))
        XCTAssertFalse(URLRequestTest.absolute("http://www.example.com:82/path/to/").componentPredicate(components))

        XCTAssertTrue(URLRequestTest.path("/path/to/something").componentPredicate(components))
        XCTAssertFalse(URLRequestTest.path("/path/to/").componentPredicate(components))

        XCTAssertTrue(URLRequestTest.query("offset=10&count=100").componentPredicate(components))
        XCTAssertFalse(URLRequestTest.query("offset=0&count=100").componentPredicate(components))

        XCTAssertTrue(URLRequestTest.queryItem(URLQueryItem(name: "count", value: "100")).componentPredicate(components))
        XCTAssertFalse(URLRequestTest.queryItem(URLQueryItem(name: "count", value: "0")).componentPredicate(components))

        XCTAssertTrue(URLRequestTest.regex("[ex]{2,}[a-z].").componentPredicate(components))
        XCTAssertFalse(URLRequestTest.regex("[xy]{2,}[a-z].").componentPredicate(components))
    }

    func testShawshankMatchElementsConvenienceInitializer() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLRequestTest(scheme: "http").componentPredicate(components))
        XCTAssertTrue(URLRequestTest(host: "www.example.com").componentPredicate(components))
        XCTAssertTrue(URLRequestTest(port: 82).componentPredicate(components))
        XCTAssertTrue(URLRequestTest(url: URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!).componentPredicate(components))
        XCTAssertTrue(URLRequestTest(absolute: "http://www.example.com:82/path/to/something?offset=10&count=100").componentPredicate(components))
        XCTAssertTrue(URLRequestTest(path: "/path/to/something").componentPredicate(components))
        XCTAssertTrue(URLRequestTest(query: "offset=10&count=100").componentPredicate(components))
        XCTAssertTrue(URLRequestTest(queryItem: URLQueryItem(name: "count", value: "100")).componentPredicate(components))
        XCTAssertTrue(URLRequestTest(regex: "[ex]{2,}[a-z].").componentPredicate(components))
    }
}
