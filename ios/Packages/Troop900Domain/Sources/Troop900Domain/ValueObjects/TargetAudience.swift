import Foundation

/// Represents the target audience for a message.
public enum TargetAudience: String, Sendable, Codable {
    case all
    case scouts
    case parents
    case leadership
    case household
    case individual
    
    public var displayName: String {
        switch self {
        case .all: return "All Users"
        case .scouts: return "Scouts"
        case .parents: return "Parents"
        case .leadership: return "Leadership"
        case .household: return "Household"
        case .individual: return "Individual"
        }
    }
}
