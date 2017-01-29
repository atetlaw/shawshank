//
//  ShankPublicAPITests.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 13/1/17.
//  Copyright © 2017 SafetyCulture. All rights reserved.
//

import XCTest
import Shawshank

class ShankPublicAPITests: XCTestCase {

    var testRequest = URLRequest(url: URL(string: "http://www.example.com")!)
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        Shawshank.release()
        super.tearDown()
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
            XCTAssertNotNil(data)
            guard let data = data else { XCTFail(); return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, String> else { XCTFail(); return }
            XCTAssertEqual(json?["test"], "json")
            expect.fulfill()
            }.resume()
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testShawshankClosureAPIMatchingDataTaskRespondingWithJSONDataFixture() {
        let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
        let request = URLRequest(url:testURL)

        Shawshank.take { (components: URLComponents) in
            return components.host == "www.example.com" && components.port == 82
        }.fixture(JSONDataFixture(["test":"json"]))

        let expect = expectation(description: "response successful")

        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            XCTAssertNil(error)
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertNotNil(data)
            guard let data = data else { XCTFail(); return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options:[]) as? Dictionary<String, String> else { XCTFail(); return }
            XCTAssertEqual(json?["test"], "json")
            expect.fulfill()
            }.resume()

        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
