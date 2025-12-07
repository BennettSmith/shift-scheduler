import Foundation

/// Represents the attendance status for a shift assignment.
public enum AttendanceStatus: String, Sendable, Codable {
    case pending
    case checkedIn = "checked_in"
    case checkedOut = "checked_out"
    case noShow = "no_show"
    case excused
    
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .checkedIn: return "Checked In"
        case .checkedOut: return "Completed"
        case .noShow: return "No Show"
        case .excused: return "Excused"
        }
    }
    
    public var isComplete: Bool {
        self == .checkedOut || self == .noShow || self == .excused
    }
}
