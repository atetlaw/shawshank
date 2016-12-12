//
//  Shawshank.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 2/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

class Shawshank: URLProtocol {

    private static var harnesses = [Harness]()
    static var isActive: Bool { return harnesses.count > 0 }

    class func take(_ with: @escaping (URLRequest) -> Bool)  -> Harness {
        self.bind()
        let harness = Harness(with)
        harnesses.append(harness)
        return harness
    }

    class func take(_ with: @escaping (URLSessionTask) -> Bool)  -> Harness {
        self.bind()
        let harness = Harness(with)
        harnesses.append(harness)
        return harness
    }

    class func take(using: Harness)  -> Harness {
        self.bind()
        harnesses.append(using)
        return using
    }

    class func take(matching: MatchElement)  -> Harness {
        self.bind()
        let harness = Harness(matching)
        harnesses.append(harness)
        return harness
    }

    class func take(all: MatchCollection)  -> Harness {
        self.bind()
        let harness = Harness(all: all)
        harnesses.append(harness)
        return harness
    }

    class func take(any: MatchCollection)  -> Harness {
        self.bind()
        let harness = Harness(any: any)
        harnesses.append(harness)
        return harness
    }

    class func take(_ taker: Taker)  -> Harness {
        self.bind()
        let harness = Harness(taker)
        harnesses.append(harness)
        return harness
    }

    @discardableResult
    class func bind(_ session: URLSession? = nil) -> Shawshank.Type {
        URLProtocol.registerClass(Shawshank.self)
        register(session: URLSession.shared)
        if let urlSession = session {
            register(session: urlSession)
        }
        return Shawshank.self
    }

    private class func register(session: URLSession) {
        var protocolClasses = [AnyClass]()

        if let existing = session.configuration.protocolClasses {
            protocolClasses.append(contentsOf: existing)
        }

        if !protocolClasses.contains(where: { $0 == Shawshank.self }) {
            protocolClasses.append(Shawshank.self)
        }

        let newConfig = session.configuration.copy()

        session.configuration.protocolClasses = protocolClasses
    }

    class func release(_ session: URLSession? = nil) {
        URLProtocol.unregisterClass(Shawshank.self)
        unregister(session: URLSession.shared)
        if let urlSession = session {
            unregister(session: urlSession)
        }
        harnesses.removeAll()
    }

    private class func unregister(session: URLSession) {
        var protocolClasses = [AnyClass]()

        if let existing = session.configuration.protocolClasses {
            protocolClasses.append(contentsOf: existing)
        }

        protocolClasses = protocolClasses.filter { $0 != Shawshank.self }
        session.configuration.protocolClasses = protocolClasses
    }

    class func harness(for request: URLRequest) -> Harness? {
        for harness in harnesses where harness.responds(to: request) {
            return harness
        }
        return nil
    }

    class func harness(for task: URLSessionTask) -> Harness? {
        for harness in harnesses where harness.responds(to: task) {
            return harness
        }
        return nil
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

