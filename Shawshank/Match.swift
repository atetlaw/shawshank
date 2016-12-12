//
//  Match.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public protocol MatchElement {
    var matches: (URLComponents) -> Bool { get }
    var taker: Taker { get }
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
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
            return self.reduce(true, { (result, match) -> Bool in
                return result && match.matches(components)
            })
        })
    }

    var any: Taker {
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
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
    case match(MatchElement)
}

extension URLComponentMatch {
    public var matches: (URLComponents) -> Bool {
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
        case .match(let matchElement):
            return matchElement.matches
        }
    }

    public var taker: Taker {
        let match = matches
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
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


