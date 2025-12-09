import Foundation

/// A type-safe identifier for Shift entities.
public struct ShiftId: Hashable, Sendable, Codable {
    public let value: String
    
    public init(_ value: String) throws {
        guard !value.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidInput("ShiftId cannot be empty")
        }
        self.value = value
    }
    
    /// Creates a ShiftId without validation. Use only when the value is known to be valid.
    public init(unchecked value: String) {
        self.value = value
    }
}

// MARK: - CustomStringConvertible

extension ShiftId: CustomStringConvertible {
    public var description: String {
        value
    }
}
