import Foundation

/// Represents the staffing status of a shift.
public enum StaffingStatus: Sendable, Codable {
    case empty
    case partial
    case full
    
    public var displayName: String {
        switch self {
        case .empty: return "Empty"
        case .partial: return "Partially Staffed"
        case .full: return "Fully Staffed"
        }
    }
    
    /// Returns a suggested color name for UI representation.
    public var colorName: String {
        switch self {
        case .empty: return "red"
        case .partial: return "yellow"
        case .full: return "green"
        }
    }
}
