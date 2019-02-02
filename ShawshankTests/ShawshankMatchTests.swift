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
        Shawshank.unbind()
        super.tearDown()
    }

    func testURLComponentTestComponentPredicate() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLComponentTest.scheme("http").componentPredicate(components))
        XCTAssertFalse(URLComponentTest.scheme("https").componentPredicate(components))

        XCTAssertTrue(URLComponentTest.host("www.example.com").componentPredicate(components))
        XCTAssertFalse(URLComponentTest.host("example.com").componentPredicate(components))

        XCTAssertTrue(URLComponentTest.port(82).componentPredicate(components))
        XCTAssertFalse(URLComponentTest.port(80).componentPredicate(components))

        XCTAssertTrue(URLComponentTest.url(URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!).componentPredicate(components))
        XCTAssertFalse(URLComponentTest.url(URL(string: "http://www.example.com:80/path/to/something")!).componentPredicate(components))

        XCTAssertTrue(URLComponentTest.absolute("http://www.example.com:82/path/to/something?offset=10&count=100").componentPredicate(components))
        XCTAssertFalse(URLComponentTest.absolute("http://www.example.com:82/path/to/").componentPredicate(components))

        XCTAssertTrue(URLComponentTest.path("/path/to/something").componentPredicate(components))
        XCTAssertFalse(URLComponentTest.path("/path/to/").componentPredicate(components))

        XCTAssertTrue(URLComponentTest.query("offset=10&count=100").componentPredicate(components))
        XCTAssertFalse(URLComponentTest.query("offset=0&count=100").componentPredicate(components))

        XCTAssertTrue(URLComponentTest.queryItem(URLQueryItem(name: "count", value: "100")).componentPredicate(components))
        XCTAssertFalse(URLComponentTest.queryItem(URLQueryItem(name: "count", value: "0")).componentPredicate(components))

        XCTAssertTrue(URLComponentTest.regex("[ex]{2,}[a-z].").componentPredicate(components))
        XCTAssertFalse(URLComponentTest.regex("[xy]{2,}[a-z].").componentPredicate(components))
    }

    func testShawshankMatchElementsConvenienceInitializer() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLComponentTest(scheme: "http").componentPredicate(components))
        XCTAssertTrue(URLComponentTest(host: "www.example.com").componentPredicate(components))
        XCTAssertTrue(URLComponentTest(port: 82).componentPredicate(components))
        XCTAssertTrue(URLComponentTest(url: URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!).componentPredicate(components))
        XCTAssertTrue(URLComponentTest(absolute: "http://www.example.com:82/path/to/something?offset=10&count=100").componentPredicate(components))
        XCTAssertTrue(URLComponentTest(path: "/path/to/something").componentPredicate(components))
        XCTAssertTrue(URLComponentTest(query: "offset=10&count=100").componentPredicate(components))
        XCTAssertTrue(URLComponentTest(queryItem: URLQueryItem(name: "count", value: "100")).componentPredicate(components))
        XCTAssertTrue(URLComponentTest(regex: "[ex]{2,}[a-z].").componentPredicate(components))
    }
}
