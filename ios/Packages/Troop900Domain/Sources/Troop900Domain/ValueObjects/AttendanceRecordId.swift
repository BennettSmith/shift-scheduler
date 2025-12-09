import Foundation

/// A type-safe identifier for AttendanceRecord entities.
public struct AttendanceRecordId: Hashable, Sendable, Codable {
    public let value: String
    
    public init(_ value: String) throws {
        guard !value.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidInput("AttendanceRecordId cannot be empty")
        }
        self.value = value
    }
    
    /// Creates an AttendanceRecordId without validation. Use only when the value is known to be valid.
    public init(unchecked value: String) {
        self.value = value
    }
}

// MARK: - CustomStringConvertible

extension AttendanceRecordId: CustomStringConvertible {
    public var description: String {
        value
    }
}
