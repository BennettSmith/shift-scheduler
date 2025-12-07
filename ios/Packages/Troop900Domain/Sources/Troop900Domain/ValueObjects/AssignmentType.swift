import Foundation

/// Represents the type of assignment (scout or parent).
public enum AssignmentType: String, Sendable, Codable {
    case scout
    case parent
    
    public var displayName: String {
        switch self {
        case .scout: return "Scout"
        case .parent: return "Parent"
        }
    }
}
