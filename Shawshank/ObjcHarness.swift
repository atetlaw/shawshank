//
//  ObjcHarness.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 1/1/17.
//  Copyright © 2017 SafetyCulture. All rights reserved.
//

import Foundation

@objc
open class ObjcHarness: NSObject {
    internal let harness: Harness

    init(withRequestPredicate predicate: @escaping RequestPredicate) {
        harness = Harness(predicate)
    }

    init(withComponentPredicate predicate: @escaping ComponentPredicate) {
        harness = Harness(predicate)
    }

    init(withSessionTaskPredicate predicate: @escaping SessionTaskPredicate) {
        harness = Harness(predicate)
    }

    func respond(_ with: @escaping (URLRequest) -> Response) {
        harness.response = .request(with)
    }

    func respond(_ with: @escaping (ShawshankURLProtocol) -> Response) {
        harness.response = .urlProtocol(with)
    }
}
