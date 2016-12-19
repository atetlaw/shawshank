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

    var testRequest = URLRequest(url: URL(string: "http://www.example.com")!)
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        Shawshank.release()
        super.tearDown()
    }

    func testShawshankMatchElements() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLComponentMatch.scheme("http").predicate(components))
        XCTAssertFalse(URLComponentMatch.scheme("https").predicate(components))

        XCTAssertTrue(URLComponentMatch.host("www.example.com").predicate(components))
        XCTAssertFalse(URLComponentMatch.host("example.com").predicate(components))

        XCTAssertTrue(URLComponentMatch.port(82).predicate(components))
        XCTAssertFalse(URLComponentMatch.port(80).predicate(components))

        XCTAssertTrue(URLComponentMatch.url(URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!).predicate(components))
        XCTAssertFalse(URLComponentMatch.url(URL(string: "http://www.example.com:80/path/to/something")!).predicate(components))

        XCTAssertTrue(URLComponentMatch.absolute("http://www.example.com:82/path/to/something?offset=10&count=100").predicate(components))
        XCTAssertFalse(URLComponentMatch.absolute("http://www.example.com:82/path/to/").predicate(components))

        XCTAssertTrue(URLComponentMatch.path("/path/to/something").predicate(components))
        XCTAssertFalse(URLComponentMatch.path("/path/to/").predicate(components))

        XCTAssertTrue(URLComponentMatch.query("offset=10&count=100").predicate(components))
        XCTAssertFalse(URLComponentMatch.query("offset=0&count=100").predicate(components))

        XCTAssertTrue(URLComponentMatch.queryItem(URLQueryItem(name: "count", value: "100")).matches(components))
        XCTAssertFalse(URLComponentMatch.queryItem(URLQueryItem(name: "count", value: "0")).matches(components))

        XCTAssertTrue(URLComponentMatch.regex("[ex]{2,}[a-z].").predicate(components))
        XCTAssertFalse(URLComponentMatch.regex("[xy]{2,}[a-z].").predicate(components))
    }

    func testShawshankMatchElementsConvenienceInitializer() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLComponentMatch(scheme: "http").matches(components))
        XCTAssertTrue(URLComponentMatch(host: "www.example.com").matches(components))
        XCTAssertTrue(URLComponentMatch(port: 82).matches(components))
        XCTAssertTrue(URLComponentMatch(url: URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!).matches(components))
        XCTAssertTrue(URLComponentMatch(absolute: "http://www.example.com:82/path/to/something?offset=10&count=100").matches(components))
        XCTAssertTrue(URLComponentMatch(path: "/path/to/something").matches(components))
        XCTAssertTrue(URLComponentMatch(query: "offset=10&count=100").matches(components))
        XCTAssertTrue(URLComponentMatch(queryItem: URLQueryItem(name: "count", value: "100")).matches(components))
        XCTAssertTrue(URLComponentMatch(regex: "[ex]{2,}[a-z].").matches(components))
    }

    func testShawshankCustomMatchElement() {

        struct CustomMatch: MatchElement {
            var predicate = { (components: URLComponents) in components.host == "www.example.com" }
        }

        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(CustomMatch().predicate(components))
        XCTAssertTrue(URLComponentMatch.match(CustomMatch()).matches(components))
    }

    func testShawshankMatchElementCollection() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        let collection1 = URLComponentMatches([.scheme("http"), .port(82), .query("offset=10&count=100")])
        XCTAssertTrue(collection1.matchAll(components))
        XCTAssertTrue(collection1.matchAny(components))

        let collection2 = URLComponentMatches([.scheme("http"), .scheme("https"), .port(81), .port(82), .port(83), .query("offset=10&count=100")])
        XCTAssertFalse(collection2.matchAll(components))
        XCTAssertTrue(collection2.matchAny(components))
    }

//    func testShawshankMatchElementCollectionXXX() {
//        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
//        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }
//
//        let collection1 = URLComponentMatch.scheme("http").predicate && URLComponentMatch.port(82).predicate
//        XCTAssertTrue(collection1.test(components))
//    }

    func testShawshankMatchingDataTask() {
        let m = URLComponentMatches([.scheme("http"), .host("www.example.com")])
        Shawshank.take(all: m).httpStatus(.httpStatus(101))

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNil(error)
            XCTAssertEqual(httpResponse.statusCode, 101)
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }

//    func testShawshankMatchingDataTaskXXX() {
//        let m = URLComponentMatches([.scheme("http"), .host("www.example.com")])
//        Shawshank.take(URLComponentMatch.scheme("http").predicate && URLComponentMatch.host("www.example.com").predicate).httpStatus(.httpStatus(101))
//
//        let expect = expectation(description: "response successful")
//
//        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
//            guard let httpResponse = response as? HTTPURLResponse else { return }
//            XCTAssertNil(error)
//            XCTAssertEqual(httpResponse.statusCode, 101)
//            expect.fulfill()
//            }.resume()
//
//        waitForExpectations(timeout: 1, handler: nil)
//    }

    func testShawshankMatchingDataTaskFailure() {
        let m = URLComponentMatches([.scheme("https"), .host("www.zebra.com")])
        Shawshank.take(all: m).httpStatus(.httpStatus(101))

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNotEqual(httpResponse.statusCode, 101)
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }
}
