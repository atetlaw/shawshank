//
//  Harness.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 10/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

public typealias RequestPredicate = (URLRequest) -> Bool
public typealias ComponentPredicate = (URLComponents) -> Bool
public typealias SessionTaskPredicate = (URLSessionTask) -> Bool

public enum Taker {
    case request(RequestPredicate)
    case component(ComponentPredicate)
    case task(SessionTaskPredicate)
}

public enum Responder {
    case request((URLRequest) -> Response)
    case urlProtocol((ShawshankURLProtocol) -> Response)
}

public class Harness {

    var takes: Taker
    var response: Responder = .request({ _ in return .none })

    public init(_ predicate: @escaping RequestPredicate) {
        takes = .request(predicate)
    }

    public init(_ predicate: @escaping ComponentPredicate) {
        takes = .component(predicate)
    }

    public init(_ predicate: @escaping SessionTaskPredicate) {
        takes = .task(predicate)
    }

    public init(_ test: URLRequestTest) {
        takes = test.taker
    }

    public init(_ taker: Taker) {
        takes = taker
    }

    public func respond(_ with: @escaping (URLRequest) -> Response) {
        response = .request(with)
    }

    public func respond(_ with: @escaping (ShawshankURLProtocol) -> Response) {
        response = .urlProtocol(with)
    }

    public func respond(with: Response) {
        response = .request({ _ in return with })
    }

    public func fixture(_ fixture: Fixture) {
        response = .request({ _ in return .fixture(fixture) })
    }

    public func error(_ error: NSError) {
        response = .request({ _ in return .error(error) })
    }

    public func http(_ http: HTTPURLResponse, data: Data? = nil) {
        response = .request({ _ in return .http(http, data) })
    }

    public func httpStatus(_ code: HTTPStatus, data: Data? = nil) {
        response = .request({ (request: URLRequest) in
            guard let url = request.url, let httpResponse = code.httpResponse(url: url) else { return .none }
            return .http(httpResponse, data)
        })
    }

    func responds(to: URLRequest) -> Bool {
        switch takes {
        case .request(let take):
            return take(to)
        case .component(let take):
            guard let components = urlComponents(request: to) else { return false }
            return take(components)
        case .task:
            return false
        }
    }

    func responds(to: URLSessionTask) -> Bool {
        switch takes {
        case .request(let take):
            guard let request = urlRequest(task: to) else { return false }
            return take(request)
        case .component(let take):
            guard let request = urlRequest(task: to) else { return false }
            guard let components = urlComponents(request: request) else { return false }
            return take(components)
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

    func urlComponents(request: URLRequest) -> URLComponents? {
        guard let url = request.url else { return nil }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return components
    }

    func urlRequest(task: URLSessionTask) -> URLRequest? {
        guard let original = task.originalRequest else {
            guard let current = task.currentRequest else { return nil }
            return current
        }
        return original
    }
}

