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
        Shawshank.unbind()
        super.tearDown()
    }
    
    func testShawshankIsEnabledViaRequest() {
        Shawshank.takeRequest { (_: URLRequest) in return true }.respond { (_: URLRequest) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testRequest)
        XCTAssertNotNil(harness)
    }

    func testShawshankIsEnabledViaProtocol() {
        Shawshank.takeSessionTask { (_: URLSessionTask) in return true }.respond { (_: ShawshankURLProtocol) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testSessionTask)
        XCTAssertNotNil(harness)
        if let response = harness?.respond(to: testRequest) {
            XCTAssertTrue(response == Response.none)
        }
    }

    func testShawshankRequestHarnessCanTakeTask() {
        Shawshank.takeRequest { (_: URLRequest) in return true }.respond { (_: URLRequest) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testSessionTask)
        XCTAssertNotNil(harness)
        if let response = harness?.respond(to: testRequest) {
            XCTAssertTrue(response == Response.none)
        }
    }

    func testShawshankTaskHarnessCannotTakeRequest() {
        Shawshank.takeSessionTask { (_: URLSessionTask) in return true }.respond { (_: ShawshankURLProtocol) in return .none }
        XCTAssertTrue(Shawshank.isActive)
        let harness = Shawshank.harness(for: testRequest)
        XCTAssertNil(harness)
        if let response = harness?.respond(to: testRequest) {
            XCTAssertTrue(response == Response.none)
        }
    }

    func testShawshankRespondsToSharedSessionRequest() {
        Shawshank.takeRequest { (_: URLRequest) in return true }.httpStatus(.httpStatus(101))
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
        Shawshank.bind(configuration).takeRequest { (_: URLRequest) in return true }.httpStatus(.httpStatus(101))

        let session = URLSession(configuration: configuration)
        XCTAssertTrue(Shawshank.isActive)
        XCTAssertTrue(session.isShawshankActive)

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
