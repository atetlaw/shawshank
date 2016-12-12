//
//  Harness.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 10/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

enum Taker {
    case request((URLRequest) -> Bool)
    case task((URLSessionTask) -> Bool)
}

enum Responder {
    case request((URLRequest) -> Response)
    case task((URLSessionTask) -> Response)
}

open class Harness {

    var takes: Taker
    var response: Responder

    init(_ closure: @escaping (URLRequest) -> Bool) {
        takes = .request(closure)
        response = .request({ _ in return .none })
    }

    init(_ closure: @escaping (URLSessionTask) -> Bool) {
        takes = .task(closure)
        response = .task({ _ in return .none })
    }

    init(_ match: MatchElement) {
        takes = match.taker
        response = .request({ _ in return .none })
    }

    init(all match: MatchCollection) {
        takes = match.all
        response = .request({ _ in return .none })
    }

    init(any match: MatchCollection) {
        takes = match.any
        response = .request({ _ in return .none })
    }

    init(_ taker: Taker) {
        takes = taker
        switch taker {
        case .task:
            response = .task({ _ in return .none })
        default:
            response = .request({ _ in return .none })
        }
    }

    func respond(_ with: @escaping (URLRequest) -> Response) {
        switch takes {
        case .request:
            response = .request(with)
        case .task:
            response = .task({ (task) in
                guard let original = task.originalRequest else {
                    guard let current = task.currentRequest else { return .none }
                    return with(current)
                }
                return with(original)
            })
        }
    }

    func respond(_ with: @escaping (URLSessionTask) -> Response) {
        response = .task(with)
    }

    func respond(with: Response) {
        response = .request({ _ in return with })
    }

    func fixture(_ fixture: Fixture) {
        response = .request({ _ in return .fixture(fixture) })
    }

    func error(_ error: NSError) {
        response = .request({ _ in return .error(error) })
    }

    func http(_ http: HTTPURLResponse, data: Data? = nil) {
        response = .request({ _ in return .http(http, data) })
    }

    func httpStatus(_ code: HTTPStatus, data: Data? = nil) {
        response = .request({ (request: URLRequest) in
            guard let url = request.url, let httpResponse = code.httpResponse(url: url) else { return .none }
            return .http(httpResponse, data)
        })
    }

    func responds(to: URLRequest) -> Bool {
        switch takes {
        case .request(let take):
            return take(to)
        case .task:
            return false
        }
    }

    func responds(to: URLSessionTask) -> Bool {
        switch takes {
        case .request(let take):
            guard let original = to.originalRequest else {
                guard let current = to.currentRequest else { return false }
                return take(current)
            }
            return take(original)
        case .task(let take):
            return take(to)
        }
    }

    func respond(to: URLRequest) -> Response {
        switch response {
        case .request(let respond):
            return respond(to)
        case .task:
            return .none //unable to respond in this way
        }
    }

    func respond(to: URLSessionTask) -> Response {
        switch response {
        case .request(let respond):
            guard let original = to.originalRequest else {
                guard let current = to.currentRequest else { return .none }
                return respond(current)
            }
            return respond(original)
        case .task(let respond):
            return respond(to)
        }
    }
}

