//
//  ShawshankStressTests.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 21/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import XCTest
@testable import Shawshank

class ShawshankStressTests: XCTestCase {
    let testAddr = "http://www.example.com:82/path/to/something?offset=10&count=100"
    let testURL = URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!
    var testRequest = URLRequest(url: URL(string: "http://www.example.com:82/path/to/something?offset=10&count=100")!)
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        Shawshank.release()
        super.tearDown()
    }
    
    func testExample() {
        
    }

}


public struct TypicalRequest: Typical {
    public typealias Subject = URLRequest

    public func test(_ s: URLRequest) -> Bool {
        return closure(s)
    }

    public var closure: (URLRequest) -> Bool
    public init(_ t: @escaping (URLRequest) -> Bool) {
        closure = t
    }
}
