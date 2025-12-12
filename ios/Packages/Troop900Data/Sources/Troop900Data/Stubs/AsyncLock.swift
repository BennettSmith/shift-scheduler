import Foundation
import os.lock

/// A thread-safe lock that can be used in async contexts.
/// Uses `os_unfair_lock` which is async-safe in Swift 6.0.
final class AsyncLock: @unchecked Sendable {
    private var _lock = os_unfair_lock()
    
    func lock() {
        os_unfair_lock_lock(&_lock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
    
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
