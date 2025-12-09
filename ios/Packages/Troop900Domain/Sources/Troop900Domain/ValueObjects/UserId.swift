import Foundation

/// A type-safe identifier for User entities.
public struct UserId: Hashable, Sendable, Codable {
    public let value: String
    
    public init(_ value: String) throws {
        guard !value.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidInput("UserId cannot be empty")
        }
        self.value = value
    }
    
    /// Creates a UserId without validation. Use only when the value is known to be valid.
    public init(unchecked value: String) {
        self.value = value
    }
}

// MARK: - CustomStringConvertible

extension UserId: CustomStringConvertible {
    public var description: String {
        value
    }
}
