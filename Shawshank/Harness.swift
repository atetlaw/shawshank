//
//  Harness.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 10/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public enum Taker {
    public typealias RequestMatcher = (URLRequest) -> Bool
    public typealias SessionTaskMatcher = (URLSessionTask) -> Bool
    case request(Taker.RequestMatcher)
    case task(Taker.SessionTaskMatcher)
}

public enum Responder {
    public typealias RequestResponder = (URLRequest) -> Response
    public typealias ProtocolResponder = (ShawshankURLProtocol) -> Response
    case request(RequestResponder)
    case urlProtocol(ProtocolResponder)
}

open class Harness {

    var takes: Taker
    var response: Responder = .request({ _ in return .none })

    init(_ closure: @escaping Taker.RequestMatcher) {
        takes = .request(closure)
    }

    init(_ closure: @escaping (URLSessionTask) -> Bool) {
        takes = .task(closure)
    }

    init(_ match: MatchElement) {
        takes = match.taker
    }

    init(all match: MatchCollection) {
        takes = match.all
    }

    init(any match: MatchCollection) {
        takes = match.any
    }

    init(_ taker: Taker) {
        takes = taker
    }

    func respond(_ with: @escaping Responder.RequestResponder) {
        response = .request(with)
    }

    func respond(_ with: @escaping Responder.ProtocolResponder) {
        response = .urlProtocol(with)
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
        case .urlProtocol:
            return .none //unable to respond in this way
        }
    }

    func respond(to: ShawshankURLProtocol) -> Response {
        switch response {
        case .request(let respond):
            return respond(to.request)
        case .urlProtocol(let respond):
            return respond(to)
        }
    }
}

