//
//  ShawshankURLProtocol+Objective-C.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 13/1/17.
//  Copyright © 2017 SafetyCulture. All rights reserved.
//

import Foundation
public class SHKShawshank: NSObject {
    @objc public class func takeWithRequestPredicate(_ with: @escaping (URLRequest) -> Bool) -> SHKHarness {
        let shim = SHKHarness(withRequestPredicate: with)
        let _ = Shawshank.take(using: shim.harness)
        return shim
    }

    @objc public class func takeWithComponentPredicate(_ with: @escaping (URLComponents) -> Bool) -> SHKHarness {
        let shim = SHKHarness(withComponentPredicate: with)
        let _ = Shawshank.take(using: shim.harness)
        return shim
    }

    @objc public class func takeWithSessionTaskPredicate(_ with: @escaping (URLSessionTask) -> Bool) -> SHKHarness {
        let shim = SHKHarness(withSessionTaskPredicate: with)
        let _ = Shawshank.take(using: shim.harness)
        return shim
    }
}


@objc public class SHKHarness: NSObject {
    internal let harness: Harness

    public init(withRequestPredicate predicate: @escaping RequestPredicate) {
        harness = Harness(predicate)
    }

    public init(withComponentPredicate predicate: @escaping ComponentPredicate) {
        harness = Harness(predicate)
    }

    public init(withSessionTaskPredicate predicate: @escaping SessionTaskPredicate) {
        harness = Harness(predicate)
    }

    @objc public func with(response: SHKResponse) {
        harness.response = .request({ _ in return .shkResponse(response) })
    }
}

@objc public class SHKResponse: NSObject {
    public var requestError: NSError?
    public var httpResponse: HTTPURLResponse?
    public var responseData: NSData?

    public override init() {
        requestError = nil
        httpResponse = nil
        responseData = nil
    }

    public init(withError: NSError?, withHTTPResponse: HTTPURLResponse?, withResponseData: NSData?) {
        requestError = withError
        httpResponse = withHTTPResponse
        responseData = withResponseData
    }

}

