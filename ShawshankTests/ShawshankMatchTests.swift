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
        let testURL = URL(string: "http://www.example.com:82/path/to/something")!
        guard let components = URLComponents(url: testURL, resolvingAgainstBaseURL: true) else { return }

        XCTAssertTrue(URLComponentMatch.scheme("http").matches(components))
        XCTAssertFalse(URLComponentMatch.scheme("https").matches(components))

        XCTAssertTrue(URLComponentMatch.host("www.example.com").matches(components))
        XCTAssertFalse(URLComponentMatch.host("example.com").matches(components))

        XCTAssertTrue(URLComponentMatch.port(82).matches(components))
        XCTAssertFalse(URLComponentMatch.port(80).matches(components))

    }

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
