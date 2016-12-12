//
//  ShawshankProtocol.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 12/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

open class ShawshankURLProtocol: URLProtocol {

    // MARK: URLProtocol methods

    open override class func canInit(with request: URLRequest) -> Bool {
        return (Shawshank.harness(for: request) != nil)
    }

    open override class func canInit(with task: URLSessionTask) -> Bool {
        return (Shawshank.harness(for: task) != nil)
    }

    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    open override func startLoading() {
        guard let harness = Shawshank.harness(for: request) else { return }

        let response = harness.respond(to: request)
        switch response {
        case .error(let error):
            client?.urlProtocol(self, didFailWithError: error)
        return // Bail out early on error
        case .http(let httpResponse, let data):
            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

        case .fixture(let fixture):
            if let url = request.url, let response = fixture.response(forURL: url) {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: fixture.data)
            }

        default: break
        }

        client?.urlProtocolDidFinishLoading(self)
    }
    
    open override func stopLoading() {}
}
