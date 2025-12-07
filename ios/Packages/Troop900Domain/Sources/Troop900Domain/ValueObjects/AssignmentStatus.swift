import Foundation

/// Represents the status of a shift assignment.
public enum AssignmentStatus: String, Sendable, Codable {
    case pending
    case confirmed
    case cancelled
    case completed
    
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        }
    }
    
    public var isActive: Bool {
        self == .pending || self == .confirmed
    }
}
