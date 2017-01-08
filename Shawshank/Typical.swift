//
//  Typical.swift
//  Typical
//
//  Created by Andrew Tetlaw on 7/1/17.
//
//

public protocol Typical {
    associatedtype Subject
    func test(_ subject: Subject) -> Bool
    init(_ predicate: @escaping (Subject) -> Bool)
}

extension Typical {
    public static func pick<T: Typical>(when: T, then: T, else: T ...) -> T {
        return T { return when.test($0) ? then.test($0) : `else`.withAll.test($0) }
    }

    public static func withAll<T: Typical>(_ tests: T ...) -> T {
        return tests.withAll
    }

    public static func withAny<T: Typical>(_ tests: T ...) -> T {
        return tests.withAny
    }
}

public func &&<T: Typical>(lhs: T, rhs: T) -> T {
    return T { return lhs.test($0) && rhs.test($0) }
}

public func ||<T: Typical>(lhs: T, rhs: T) -> T {
    return T { return lhs.test($0) || rhs.test($0) }
}

public prefix func !<T: Typical>(_ typical: T) -> T {
    return T { !(typical.test($0)) }
}

extension Collection where Iterator.Element: Typical {
    public var withAll: Iterator.Element {
        return Iterator.Element {
            for typical in self {
                guard typical.test($0) else { return false }
            }
            return true
        }
    }

    public var withAny: Iterator.Element {
        return Iterator.Element {
            for typical in self {
                guard !typical.test($0) else { return true }
            }
            return false
        }
    }
}

public final class Matching<T>: Typical {
    public typealias Subject = T
    private var predicate: (T) -> Bool
    public init(_ test: @escaping (T) -> Bool) {
        predicate = test
    }
    public func test(_ s: T) -> Bool {
        return predicate(s)
    }
}
