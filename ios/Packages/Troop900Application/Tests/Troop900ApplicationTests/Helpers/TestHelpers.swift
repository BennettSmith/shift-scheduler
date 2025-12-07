import Foundation
import Testing
import Troop900Domain

/// Common test utilities and assertion helpers
public enum TestHelpers {
    
    /// Generates a unique ID for test entities
    public static func uniqueId(prefix: String = "test") -> String {
        "\(prefix)-\(UUID().uuidString.prefix(8))"
    }
    
    /// Generates a unique email for test users
    public static func uniqueEmail() -> String {
        "test-\(UUID().uuidString.prefix(8))@example.com"
    }
    
    /// Generates a random invite code (8 characters, no ambiguous chars)
    public static func randomInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
}

// MARK: - Result Helpers

/// Extension to help with Result types in tests
public extension Result where Success: Equatable {
    /// Checks if the result is a success with the expected value
    func isSuccess(with expectedValue: Success) -> Bool {
        switch self {
        case .success(let value):
            return value == expectedValue
        case .failure:
            return false
        }
    }
}

public extension Result {
    /// Returns the success value or nil
    var successValue: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the error or nil
    var failureError: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - DomainError Testing Helpers

/// Extension to help identify specific DomainError types in tests
public extension DomainError {
    /// Returns true if this is an unauthorized error
    var isUnauthorized: Bool {
        if case .unauthorized = self { return true }
        return false
    }
    
    /// Returns true if this is a not found error
    var isNotFound: Bool {
        switch self {
        case .userNotFound, .shiftNotFound, .assignmentNotFound,
             .attendanceRecordNotFound, .householdNotFound,
             .inviteCodeNotFound, .seasonNotFound, .templateNotFound,
             .messageNotFound:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if this is an invalid input error
    var isInvalidInput: Bool {
        if case .invalidInput = self { return true }
        return false
    }
}

// MARK: - Async Stream Helpers

/// Helper to collect items from an async throwing stream
public func collectStream<T>(_ stream: AsyncThrowingStream<T, Error>, maxItems: Int = 10) async throws -> [T] {
    var items: [T] = []
    for try await item in stream {
        items.append(item)
        if items.count >= maxItems {
            break
        }
    }
    return items
}

/// Helper to get the first item from an async throwing stream
public func firstFromStream<T>(_ stream: AsyncThrowingStream<T, Error>) async throws -> T? {
    for try await item in stream {
        return item
    }
    return nil
}

// MARK: - Call Tracking

/// A generic call tracker for recording method invocations in mocks
public final class CallTracker<T: Sendable>: @unchecked Sendable {
    private var _calls: [T] = []
    private let lock = NSLock()
    
    public init() {}
    
    /// Records a call with the given arguments
    public func record(_ call: T) {
        lock.lock()
        defer { lock.unlock() }
        _calls.append(call)
    }
    
    /// Returns all recorded calls
    public var calls: [T] {
        lock.lock()
        defer { lock.unlock() }
        return _calls
    }
    
    /// Returns the number of calls
    public var callCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _calls.count
    }
    
    /// Returns true if any calls were made
    public var wasCalled: Bool {
        callCount > 0
    }
    
    /// Returns the last call, if any
    public var lastCall: T? {
        lock.lock()
        defer { lock.unlock() }
        return _calls.last
    }
    
    /// Resets the call history
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        _calls.removeAll()
    }
}

// MARK: - Error Throwing Helpers

/// A configurable error for testing error paths
public struct TestError: Error, Equatable {
    public let message: String
    
    public init(_ message: String = "Test error") {
        self.message = message
    }
}
