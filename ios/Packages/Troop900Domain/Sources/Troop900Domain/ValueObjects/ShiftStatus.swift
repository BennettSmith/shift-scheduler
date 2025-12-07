import Foundation

/// Represents the status of a shift.
public enum ShiftStatus: String, Sendable, Codable {
    case draft
    case published
    case cancelled
    case completed
    
    public var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .published: return "Published"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        }
    }
    
    public var canAcceptSignups: Bool {
        self == .published
    }
    
    public var isEditable: Bool {
        self == .draft || self == .published
    }
}
