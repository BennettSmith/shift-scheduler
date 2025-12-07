import Foundation

/// Represents the status of a user account.
public enum AccountStatus: String, Sendable, Codable {
    case pending
    case active
    case inactive
    case deactivated
    
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .deactivated: return "Deactivated"
        }
    }
    
    public var canSignUpForShifts: Bool {
        self == .active
    }
}
