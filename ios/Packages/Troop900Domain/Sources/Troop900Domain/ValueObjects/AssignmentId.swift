import Foundation

/// A type-safe identifier for Assignment entities.
public struct AssignmentId: Hashable, Sendable, Codable {
    public let value: String
    
    public init(_ value: String) throws {
        guard !value.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidInput("AssignmentId cannot be empty")
        }
        self.value = value
    }
    
    /// Creates an AssignmentId without validation. Use only when the value is known to be valid.
    public init(unchecked value: String) {
        self.value = value
    }
}

// MARK: - CustomStringConvertible

extension AssignmentId: CustomStringConvertible {
    public var description: String {
        value
    }
}
