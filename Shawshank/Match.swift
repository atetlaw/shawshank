//
//  Match.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

protocol MatchElement {
    var matcher: (URLComponents) -> Bool { get }
    var taker: Taker { get }
}

protocol MatchCollection {
    var matches: AnyCollection<MatchElement> { get }
}

extension MatchCollection {
    var all: Taker {
        let tests = matches
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
            return tests.reduce(true, { (result, match) -> Bool in
                return result && match.matcher(components)
            })
        })
    }

    var any: Taker {
        let tests = matches
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
            return tests.reduce(false, { (result, match) -> Bool in
                return result || match.matcher(components)
            })
        })
    }
}

enum Match: MatchElement {
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

extension Match {
    var matcher: (URLComponents) -> Bool {
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
            return matchElement.matcher
        }
    }

    var taker: Taker {
        let matches = matcher
        return .request({ (request: URLRequest) -> Bool in
            guard let url = request.url else { return false }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
            return matches(components)
        })
    }
}

extension Match {
    static func all(_ with: Matches) -> Taker {
        return with.all
    }

    static func any(_ with: Matches) -> Taker {
        return with.any
    }
}

struct Matches: MatchCollection {
    var matches: AnyCollection<MatchElement>

    init(_ with: AnyCollection<MatchElement>) {
        matches = with
    }

    init<C: Collection>(_ with: C) where C.Iterator.Element == MatchElement  {
        matches = AnyCollection(Array(with))
    }

    init(_ with: [MatchElement])  {
        matches = AnyCollection(with)
    }
}

