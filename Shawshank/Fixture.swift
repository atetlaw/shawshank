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

struct TestFixture: Fixture {
    var data: Data
    var httpStatus: HTTPStatus
    var headerFields: [String : String]
}

public enum BundleFixtureType {
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
        case .plist:
            return ""
        case .jpg:
            return "image/jpeg"
        case .png:
            return "image/png"
        default:
            return nil
        }
    }
}

struct BundleFixture: Fixture {
    var type: BundleFixtureType
    var httpStatus: HTTPStatus
    var headerFields: [String : String]
    var data: Data

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
