import Foundation

/// Represents the role a user has in the system.
public enum UserRole: String, Sendable, CaseIterable, Codable {
    case scout
    case parent
    case scoutmaster
    case assistantScoutmaster = "assistant_scoutmaster"
    
    public var displayName: String {
        switch self {
        case .scout: return "Scout"
        case .parent: return "Parent"
        case .scoutmaster: return "Scoutmaster"
        case .assistantScoutmaster: return "Assistant Scoutmaster"
        }
    }
    
    public var isLeadership: Bool {
        self == .scoutmaster || self == .assistantScoutmaster
    }
}
