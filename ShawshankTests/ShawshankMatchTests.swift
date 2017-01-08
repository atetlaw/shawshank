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

    func testShawshankMatchElementCollection() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        let request = URLRequest(url:testURL)
        XCTAssertTrue([URLRequestTest.scheme("http"), URLRequestTest.port(82), URLRequestTest.query("offset=10&count=100")].withAll.test(request))
        XCTAssertTrue([URLRequestTest.scheme("http"), URLRequestTest.port(82), URLRequestTest.query("offset=10&count=100")].withAny.test(request))

        XCTAssertFalse((URLRequestTest(scheme: "http") && URLRequestTest(scheme: "https")).test(request))
        XCTAssertTrue((URLRequestTest(scheme: "http") || URLRequestTest(scheme: "https")).test(request))
        XCTAssertTrue((!URLRequestTest(scheme: "https")).test(request))
    }


    func testShawshankMatchingDataTask() {
        Shawshank.take(matching: .scheme("http") && .host("www.example.com")).httpStatus(.httpStatus(101))

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNil(error)
            XCTAssertEqual(httpResponse.statusCode, 101)
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testShawshankMatchingDataTaskRespondingWithJSONDataFixture() {

        Shawshank.take(matching: !.scheme("http") || .host("www.example.com")).fixture(JSONDataFixture(["test":"json"]))

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNil(error)
            XCTAssertEqual(httpResponse.statusCode, 200)
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testShawshankMatchingDataTaskFailure() {
        Shawshank.take(matching: .scheme("http") && .host("www.zebra.com")).httpStatus(.httpStatus(101))

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNotEqual(httpResponse.statusCode, 101)
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }
}
