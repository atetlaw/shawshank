//
//  Fixture.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public enum Response {
    case none
    case error(NSError)
    case http(HTTPURLResponse, Data?)
    case data(Data?)
    case fixture(Fixture)
}

public enum HTTPStatus {
    case success
    case notPermitted
    case notFound
    case serverError
    case httpStatus(Int)

    var code: Int {
        switch self {
        case .success:
            return 200
        case .notPermitted:
            return 304
        case .serverError:
            return 500
        case .httpStatus(let code):
            return code
        default:
            return 404
        }
    }

    func httpResponse(url: URL, httpVersion: String? = nil, headerFields: [String : String]? = nil) -> HTTPURLResponse? {
        return HTTPURLResponse(url: url, statusCode: self.code, httpVersion: httpVersion, headerFields: headerFields)
    }
}


