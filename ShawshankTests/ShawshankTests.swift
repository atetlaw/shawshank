//
//  ShawshankTests.swift
//  ShawshankTests
//
//  Created by Andrew Tetlaw on 2/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import XCTest
@testable import Shawshank

class ShawshankTests: XCTestCase {
    var testRequest = URLRequest(url: URL(string: "http://www.example.com")!)
    var testSessionTask = URLSession.shared.dataTask(with: URL(string: "http://www.example.com")!)
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        Shawshank.release()
        super.tearDown()
    }
    
    func testShawshankIsEnabledViaRequest() {
        Shawshank.take { (_: URLRequest) in return true }.respond { (_: URLRequest) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testRequest)
        XCTAssertNotNil(harness)
        if let response = harness?.respond(to: testRequest) {
//            XCTAssertTrue(response == Response.none)
        }
    }

    func testShawshankIsEnabledViaTask() {
        Shawshank.take { (_: URLSessionTask) in return true }.respond { (_: URLSessionTask) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testSessionTask)
        XCTAssertNotNil(harness)
    }

    func testShawshankRequestHarnessCanTakeTask() {
        Shawshank.take { (_: URLRequest) in return true }.respond { (_: URLRequest) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testSessionTask)
        XCTAssertNotNil(harness)
    }

    func testShawshankTaskHarnessCannotTakeRequest() {
        Shawshank.take { (_: URLSessionTask) in return true }.respond { (_: URLSessionTask) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testRequest)
        XCTAssertNil(harness)
    }

    func testShawshankRespondsToSharedSessionRequest() {
        Shawshank.take { (_: URLRequest) in return true }.httpStatus(.httpStatus(101))
        XCTAssertTrue(Shawshank.isActive)

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNil(error)
            XCTAssertEqual(httpResponse.statusCode, 101)
            expect.fulfill()
        }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testShawshankRespondsToCustomSessionRequest() {
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        Shawshank.bind(session).take { (_: URLRequest) in return true }.httpStatus(.httpStatus(101))

        XCTAssertTrue(Shawshank.isActive)

        let expect = expectation(description: "response successful")

        session.dataTask(with: testRequest) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNil(error)
            XCTAssertEqual(httpResponse.statusCode, 101)
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }
}
