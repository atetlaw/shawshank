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

    func testShawshankMatching() {
        let m = Matches([Match.scheme("http"), Match.host("www.example.com")])

        Shawshank.take(all: m).respond { (_: URLRequest) in return .none }
        Shawshank.take(matching: Match.scheme("http")).respond { (_: URLRequest) in return .none }
    }
}
