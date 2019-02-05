//
//  Fixture.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 11/12/16.
//  Copyright © 2016 Andrew Tetlaw. All rights reserved.
//

import Foundation

public enum HTTPStatus: Equatable {
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

public func ==(lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
    return lhs.code == rhs.code
}

public enum Response {
    case none
    case error(NSError)
    case http(HTTPURLResponse, Data?)
    case data(Data?)
    case fixture(Fixture)
}

//public func ==(lhs: Response, rhs: Response) -> Bool {
//    switch (lhs, rhs) {
//    case (let .error(error1), let .error(error2)):
//        return error1.isEqualTo(error: error2)
//
//    case (let .http(response1, data1), let .http(response2, data2)):
//        return response1.isEqualTo(response: response2) && data1 == data2
//
//    case (let .data(data1), let .data(data2)):
//        return data1 == data2
//
//    case (let .fixture(fixture1), let .fixture(fixture2)):
//        return fixture1 == fixture2
//
//    case (.none, .none):
//        return true
//
//    default:
//        return false
//    }
//}

//extension NSError {
//    open override func isEqual(_ object: Any?) -> Bool {
//        guard let error = object as? NSError else { return false }
//        return isEqualTo(error: error)
//    }
//
//    open func isEqualTo(error: NSError) -> Bool {
//        guard self !== error else { return true } // shortcut if same reference
//        return error.hash == hash
//    }
//}
//
//extension HTTPURLResponse {
//    open override func isEqual(_ object: Any?) -> Bool {
//        guard let response = object as? HTTPURLResponse else { return false }
//        return isEqualTo(response: response)
//    }
//
//    open func isEqualTo(response: HTTPURLResponse) -> Bool {
//        guard self !== response else { return true } // shortcut if same reference
//        return response.hash == hash
//    }
//}


