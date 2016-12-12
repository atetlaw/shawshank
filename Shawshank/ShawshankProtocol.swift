//
//  ShawshankProtocol.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 12/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

class ShawshankProtocol: URLProtocol {


    private var testResponse: Response? {
        guard let harness = testHarness else { return nil }

        switch harness.response {
        case .request:
            return harness.respond(to: request)
        default:
            if let sessionTask = task {
                return harness.respond(to: sessionTask)
            } else {
                return harness.respond(to: request)
            }
        }
    }

    private var testHarness: Harness? {
        return Shawshank.harness(for: request)
    }

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
        guard let response = testResponse else { return }

        switch response {
        case .error(let error):
            client?.urlProtocol(self, didFailWithError: error)
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
        default: ()
        }
    }
    
    open override func stopLoading() {
        
    }
}
