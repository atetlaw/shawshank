//
//  Typical.swift
//  Typical
//
//  Created by Andrew Tetlaw on 18/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

public protocol Typical {
    associatedtype Subject
    init(_ test: @escaping (Subject) -> Bool)
    var test: (Subject) -> Bool { get }
}

extension Typical {
    static var never: Self { return Self { _ in return false } }
    static var always: Self { return Self { _ in return true } }
}

public func &&<T: Typical>(lhs: T, rhs: T) -> T {
    return T { lhs.test($0) && rhs.test($0) }
}

public func ||<T: Typical>(lhs: T, rhs: T) -> T {
    return T { lhs.test($0) || rhs.test($0) }
}

public prefix func !<T: Typical>(_ typical: T) -> T {
    return T { !typical.test($0) }
}

public func all<C: Collection, T: Typical>(_ collect: C) -> T where C.Iterator.Element == T {
    return T { subject in
        for typical in collect {
            guard typical.test(subject) else { return false }
        }
        return true
    }
}

public func any<C: Collection, T: Typical>(_ collect: C) -> T where C.Iterator.Element == T {
    return T { subject in
        for typical in collect {
            guard !typical.test(subject) else { return true }
        }
        return false
    }
}

public func all<T: Typical>(_ tests: T ...) -> T {
    return all(tests)
}

public func any<T: Typical>(_ tests: T ...) -> T {
    return any(tests)
}

public func pick<T: Typical>(when: T, then: T, else: T ...) -> T {
    return T {
        return when.test($0) ? then.test($0) : all(`else`).test($0)
    }
}
