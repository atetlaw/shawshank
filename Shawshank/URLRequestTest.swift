//
//  Match.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public enum URLRequestTest: Typical {
    public typealias Subject = URLRequest

    case scheme(String)
    case host(String)
    case port(Int)
    case url(URL)
    case absolute(String)
    case path(String)
    case query(String)
    case queryItem(URLQueryItem)
    case regex(String)
    case request((URLRequest) -> Bool)

    public init(scheme: String) {
        self = .scheme(scheme)
    }

    public init(host: String) {
        self = .host(host)
    }

    public init(port: Int) {
        self = .port(port)
    }

    public init(url: URL) {
        self = .url(url)
    }

    public init(absolute: String) {
        self = .absolute(absolute)
    }

    public init(path: String) {
        self = .path(path)
    }

    public init(query: String) {
        self = .query(query)
    }

    public init(queryItem: URLQueryItem) {
        self = .queryItem(queryItem)
    }

    public init(regex: String) {
        self = .regex(regex)
    }

    public init(_ closure: @escaping (URLRequest) -> Bool) {
        self = .request(closure)
    }

    public func test(_ request: URLRequest) -> Bool {
        switch self {
        case .request(let closure):
            return closure(request)
        default:
            let matches = componentPredicate
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
            return matches(components)
        }
    }

    public static func build(_ tests: URLRequestTest ...) -> URLRequestTest {
        return all(tests)
    }
}

extension URLRequestTest {

    public var taker: Taker {
        return .request(test)
    }

    var componentPredicate: ComponentPredicate {
        switch self {
        case .scheme(let scheme):
            return { scheme == $0.scheme }
        case .host(let host):
            return { host == $0.host }
        case .port(let port):
            return { port == $0.port }
        case .url(let url):
            return { url == $0.url }
        case .absolute(let absolute):
            return { absolute == $0.url?.absoluteString }
        case .path(let path):
            return { path == $0.path }
        case .query(let query):
            return { ($0.query?.contains(query)) ?? false }
        case .queryItem(let item):
            return { ($0.queryItems?.contains(item)) ?? false }
        case .regex(let regex):
            return { (($0.url?.absoluteString.range(of: regex, options: .regularExpression)) != nil) }
        default:
            return { _ in return false }
        }
    }
}


