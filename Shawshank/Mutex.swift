//
//  Mutex.swift
//  Shawshank
//
//  Created by Andrew Tetlaw on 12/12/16.
//  Copyright © 2016 SafetyCulture. All rights reserved.
//

import Foundation

// https://www.cocoawithlove.com/blog/2016/06/02/threads-and-mutexes.html

final class Mutex {
    private var mutex = pthread_mutex_t()

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func sync<T>(execute work: () throws -> T) rethrows -> T {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        return try work()
    }

    public func trySync<T>(execute work: () throws -> T) rethrows -> T? {
        guard (pthread_mutex_trylock(&mutex) == 0) else { return nil }
        defer { pthread_mutex_unlock(&mutex) }
        return try work()
    }
}


