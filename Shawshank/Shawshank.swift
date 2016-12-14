//
//  Shawshank.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 2/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

class Shawshank {

    private static var harnesses = [Harness]()
    private static var protocolRegistered: Bool = false

    static var isActive: Bool { return harnesses.count > 0 }

    class func take(_ with: @escaping Taker.RequestMatcher) -> Harness {
        self.bind()
        let harness = Harness(with)
        harnesses.append(harness)
        return harness
    }

    class func take(_ with: @escaping Taker.SessionTaskMatcher) -> Harness {
        self.bind()
        let harness = Harness(with)
        harnesses.append(harness)
        return harness
    }

    class func take(using: Harness) -> Harness {
        self.bind()
        harnesses.append(using)
        return using
    }

    class func take(matching: MatchElement) -> Harness {
        self.bind()
        let harness = Harness(matching)
        harnesses.append(harness)
        return harness
    }

    class func take(all: MatchCollection) -> Harness {
        self.bind()
        let harness = Harness(all: all)
        harnesses.append(harness)
        return harness
    }

    class func take(any: MatchCollection) -> Harness {
        self.bind()
        let harness = Harness(any: any)
        harnesses.append(harness)
        return harness
    }

    class func take(_ taker: Taker) -> Harness {
        self.bind()
        let harness = Harness(taker)
        harnesses.append(harness)
        return harness
    }

    @discardableResult
    class func bind(_ config: URLSessionConfiguration? = nil) -> Shawshank.Type {
        register()
        if let cfg = config {
            cfg.registerShawshank()
        }
        return Shawshank.self
    }

    class func release(_ session: URLSession? = nil) {
        unregister()
    }

    private class func register() {

        let shouldRegister = Mutex().sync { () -> Bool in 
            guard !protocolRegistered else { return false }
            protocolRegistered = true
            return true
        }

        if shouldRegister {
            URLProtocol.registerClass(ShawshankURLProtocol.self)
        }
    }

    private class func unregister() {
        Mutex().sync {
            harnesses.removeAll()
            protocolRegistered = false
        }

        URLProtocol.unregisterClass(ShawshankURLProtocol.self)
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
}

extension URLSession {
    public var isShawshankActive: Bool {
        return configuration.isShawshankActive
    }
}

extension URLSessionConfiguration {
    public var isShawshankActive: Bool {
        return protocolClasses?.contains(where: { $0 == ShawshankURLProtocol.self }) ?? false
    }

    public func registerShawshank() {
        guard let existing = protocolClasses else {
            protocolClasses = [ShawshankURLProtocol.self]
            return
        }
        guard !existing.contains(where: { $0 == ShawshankURLProtocol.self }) else { return }

        var protocols: [AnyClass] = [ShawshankURLProtocol.self]
        protocols.append(contentsOf: existing)
        protocolClasses = protocols
    }
}

