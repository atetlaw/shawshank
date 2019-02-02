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

    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    open override func startLoading() {
        guard let harness = Shawshank.harness(for: request) else { return }

        let response = harness.respond(to: request)
        switch response {
        case .none:
            break
        case .error(let error):
            respond(with: error)

        case .http(let httpResponse, let data):
            respond(with: httpResponse, data: data)

        case .data(let data):
            if let url = request.url, let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil) {
                respond(with: response, data: data)
            }

        case .fixture(let fixture):
            if let url = request.url, let response = fixture.response(forURL: url) {
                respond(with: response, data: fixture.data)
            }

        case .shkResponse(let response):
            respond(with: response)

        }

        client?.urlProtocolDidFinishLoading(self)
    }
    
    open override func stopLoading() {}

    private func respond(with: NSError) {
        client?.urlProtocol(self, didFailWithError: with)
    }

    private func respond(with: HTTPURLResponse, data: Data?) {
        client?.urlProtocol(self, didReceive: with, cacheStoragePolicy: .notAllowed)
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
    }

    private func respond(with: SHKResponse) {
        if let error = with.requestError {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let response = with.httpResponse {
            respond(with: response, data: with.responseData as Data?)
        }
    }
}
