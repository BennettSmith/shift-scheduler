import Foundation

/// Represents the status of a season.
public enum SeasonStatus: String, Sendable, Codable {
    case draft
    case active
    case completed
    case archived
    
    public var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .completed: return "Completed"
        case .archived: return "Archived"
        }
    }
    
    public var isActive: Bool {
        self == .active
    }
}
