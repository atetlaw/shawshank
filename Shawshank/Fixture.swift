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

struct TestFixture: Fixture {
    var data: Data
    var httpStatus: HTTPStatus
    var headerFields: [String : String]
}

struct JSONDataFixture: Fixture {
    var data: Data
    var httpStatus: HTTPStatus
    var headerFields: [String : String]

    init(_ source: [String : String], status: HTTPStatus? = nil) {
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
    case resource(String, String)
    case html(String)
    case json(String)
    case xml(String)
    case plist(String)
    case jpg(String)
    case png(String)

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
    case (let .resource(name1, ext1), let .resource(name2, ext2)):
        return name1 == name2 && ext1 == ext2

    case (let .html(name1), let .html(name2)):
        return name1 == name2

    case (let .json(name1), let .json(name2)):
        return name1 == name2

    case (let .xml(name1), let .xml(name2)):
        return name1 == name2

    case (let .plist(name1), let .plist(name2)):
        return name1 == name2

    case (let .jpg(name1), let .jpg(name2)):
        return name1 == name2

    case (let .png(name1), let .png(name2)):
        return name1 == name2

    case (.empty, .empty):
        return true

    default:
        return false
    }
}

public struct BundleFixture: Fixture, Equatable {
    var type: BundleFixtureType
    public var httpStatus: HTTPStatus
    public var headerFields: [String : String]
    public var data: Data

    init(type t: BundleFixtureType, status: HTTPStatus? = nil) {
        type = t

        var bundleData: Data?
        switch type {
        case .resource(let name, let ext):
            bundleData = Bundle(for: Shawshank.self).fixture(named: name, withExension: ext)
        case .html(let name):
            bundleData = Bundle(for: Shawshank.self).html(named: name)
        case .json(let name):
            bundleData = Bundle(for: Shawshank.self).json(named: name)
        case .plist(let name):
            bundleData = Bundle(for: Shawshank.self).plist(named: name)
        case .jpg(let name):
            bundleData = Bundle(for: Shawshank.self).jpg(named: name)
        case .png(let name):
            bundleData = Bundle(for: Shawshank.self).png(named: name)
        default:
            bundleData = Data()
        }

        data = bundleData ?? Data()

        if let s = status {
            httpStatus = s
        } else {
            httpStatus = data.isEmpty ? .notFound : .success
        }

        if let content = type.contentType {
            headerFields = ["Content-Type" : content]
        } else {
            headerFields = [:]
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
    func fixture(named: String, withExension ext: String) -> Data? {
        guard let resourceURL = url(forResource: named, withExtension: ext) else { return nil }
        return try? Data(contentsOf: resourceURL)
    }

    func html(named: String) -> Data? {
        return fixture(named: named, withExension: "html")
    }

    func json(named: String) -> Data? {
        return fixture(named: named, withExension: "json")
    }

    func plist(named: String) -> Data? {
        return fixture(named: named, withExension: "plist")
    }

    func jpg(named: String) -> Data? {
        return fixture(named: named, withExension: "jpg")
    }

    func png(named: String) -> Data? {
        return fixture(named: named, withExension: "png")
    }
}
