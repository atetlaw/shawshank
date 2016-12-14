//
//  Match.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public protocol MatchElement {
    typealias Matcher = (URLComponents) -> Bool
    var matches: Matcher { get }
    var taker: Taker { get }
}

public func && (lhs: @escaping MatchElement.Matcher, rhs: @escaping MatchElement.Matcher) -> MatchElement.Matcher {
    return { components in lhs(components) && rhs(components) }
}

public func || (lhs: @escaping MatchElement.Matcher, rhs: @escaping MatchElement.Matcher) -> MatchElement.Matcher {
    return { components in lhs(components) || rhs(components) }
}

public prefix func ! (rhs: @escaping MatchElement.Matcher) -> MatchElement.Matcher {
    return { components in !rhs(components) }
}

public protocol MatchCollection {
    var matches: [MatchElement] { get }
}

extension MatchCollection {
    var all: Taker {
        return matches.all
    }

    var any: Taker {
        return matches.any
    }
}

extension Collection where Iterator.Element == MatchElement {
    var all: Taker {
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
            return self.reduce(true, { (result, match) -> Bool in
                return result && match.matches(components)
            })
        })
    }

    var any: Taker {
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
            return self.reduce(false, { (result, match) -> Bool in
                return result || match.matches(components)
            })
        })
    }
}

public enum URLComponentMatch: MatchElement {
    case scheme(String)
    case host(String)
    case port(Int)
    case url(URL)
    case absolute(String)
    case path(String)
    case query(String)
    case queryItem(URLQueryItem)
    case regex(String)
    case match(MatchElement)

    init(scheme: String) {
        self = .scheme(scheme)
    }

    init(host: String) {
        self = .host(host)
    }

    init(port: Int) {
        self = .port(port)
    }

    init(url: URL) {
        self = .url(url)
    }

    init(absolute: String) {
        self = .absolute(absolute)
    }

    init(path: String) {
        self = .path(path)
    }

    init(query: String) {
        self = .query(query)
    }

    init(queryItem: URLQueryItem) {
        self = .queryItem(queryItem)
    }

    init(regex: String) {
        self = .regex(regex)
    }

    init(match: MatchElement) {
        self = .match(match)
    }
}

extension URLComponentMatch {
    public var matches: MatchElement.Matcher {
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
        case .match(let matchElement):
            return matchElement.matches
        }
    }

    public var taker: Taker {
        let match = matches
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return false }
            return match(components)
        })
    }
}

public struct Matches<E: MatchElement>: MatchCollection {
    public var matches: [MatchElement] {
        return [MatchElement](internalMatches.map({$0 as MatchElement}))
    }

    private var internalMatches: AnyCollection<E>

    init(_ with: AnyCollection<E>) {
        internalMatches = with
    }

    init<C: Collection>(_ with: C) where C.Iterator.Element == E {
        internalMatches = AnyCollection(Array(with))
    }
}

public typealias URLComponentMatches = Matches<URLComponentMatch>


