//
//  Fixture.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public protocol Fixture {
    var data: Data { get }
    var httpStatus: HTTPStatus { get }
    var headerFields: [String : String] { get }
}

extension Fixture {
    func response(forURL: URL) -> HTTPURLResponse? {
        return HTTPURLResponse(url: forURL, statusCode: httpStatus.code, httpVersion: "HTTP/1.1", headerFields: headerFields)
    }
}

public func ==(lhs: Fixture, rhs: Fixture) -> Bool {
    return lhs.httpStatus == rhs.httpStatus &&
        lhs.data == rhs.data &&
        lhs.headerFields == rhs.headerFields
}

public struct TestFixture: Fixture {
    public var data: Data
    public var httpStatus: HTTPStatus
    public var headerFields: [String : String]
}

public struct JSONDataFixture: Fixture {
    public var data: Data
    public var httpStatus: HTTPStatus
    public var headerFields: [String : String]

    public init(_ source: [String : Any], status: HTTPStatus? = nil) {
        let json = try? JSONSerialization.data(withJSONObject: source, options: .prettyPrinted)
        data = (json ?? Data())

        headerFields = ["Content-Type":"application/json; charset=utf-8"]

        if let s = status {
            httpStatus = s
        } else {
            httpStatus = data.isEmpty ? .notFound : .success
        }
    }
}

public enum BundleFixtureType: Equatable {
    case empty
    case resource
    case html
    case json
    case xml
    case plist
    case jpg
    case png

    var contentType: String? {
        switch self {
        case .html:
            return "text/html"
        case .json:
            return "application/json; charset=utf-8"
        case .xml:
            return "application/xml; charset=utf-8"
        case .plist:
            return "application/xml; charset=utf-8"
        case .jpg:
            return "image/jpeg"
        case .png:
            return "image/png"
        default:
            return nil
        }
    }
}

public func ==(lhs: BundleFixtureType, rhs: BundleFixtureType) -> Bool {
    switch (lhs, rhs) {
    case (.resource, .resource),
         (.html, .html),
         (.json, .json),
         (.xml, .xml),
         (.plist, .plist),
         (.jpg, .jpg),
         (.png, .png),
         (.empty, .empty):
        return true

    default:
        return false
    }
}

public struct BundleFixture: Fixture, Equatable {
    public var type: BundleFixtureType
    public var httpStatus: HTTPStatus
    public var headerFields: [String : String]
    public var data: Data

    public init(type t: BundleFixtureType, status: HTTPStatus? = nil, headers: [String : String]? = nil, data d: Data? = nil) {
        type = t
        data = d ?? Data()
        headerFields = headers ?? [:]

        if let s = status {
            httpStatus = s
        } else {
            httpStatus = data.isEmpty ? .notFound : .success
        }

        if let content = type.contentType {
            headerFields["Content-Type"] = content
        }
    }
}

public func ==(lhs: BundleFixture, rhs: BundleFixture) -> Bool {
    return lhs.type == rhs.type &&
        lhs.httpStatus == rhs.httpStatus &&
        lhs.data == rhs.data &&
        lhs.headerFields == rhs.headerFields
}

extension Bundle {
    public func fixtureData(named: String, withExension ext: String) -> Data? {
        guard let resourceURL = url(forResource: named, withExtension: ext) else { return nil }
        return try? Data(contentsOf: resourceURL)
    }

    public func html(named: String) -> BundleFixture {
        return BundleFixture(type: .html, data: fixtureData(named: named, withExension: "html"))
    }

    public func json(named: String) -> BundleFixture {
        return BundleFixture(type: .json, data: fixtureData(named: named, withExension: "json"))
    }

    public func plist(named: String) -> BundleFixture {
        return BundleFixture(type: .plist, data: fixtureData(named: named, withExension: "plist"))
    }

    public func jpg(named: String) -> BundleFixture {
        return BundleFixture(type: .jpg, data: fixtureData(named: named, withExension: "jpg"))
    }

    public func png(named: String) -> BundleFixture {
        return BundleFixture(type: .png, data: fixtureData(named: named, withExension: "png"))
    }
}
