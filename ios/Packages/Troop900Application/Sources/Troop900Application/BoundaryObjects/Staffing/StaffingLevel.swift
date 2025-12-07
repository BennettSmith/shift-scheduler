import Foundation
import Troop900Domain

/// Detailed staffing level indicator for committee visibility.
/// More granular than StaffingStatus to highlight critical understaffing.
public enum StaffingLevel: String, Sendable, Codable {
    case critical   // Significantly understaffed (< 50% filled)
    case low        // Understaffed (50-80% filled)
    case ok         // Adequately staffed (80-100% filled)
    case full       // Fully staffed (100% filled)
    
    public var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .low: return "Low"
        case .ok: return "OK"
        case .full: return "Full"
        }
    }
    
    public var priority: Int {
        switch self {
        case .critical: return 0
        case .low: return 1
        case .ok: return 2
        case .full: return 3
        }
    }
    
    /// Calculate staffing level based on current vs required volunteers.
    public static func calculate(current: Int, required: Int) -> StaffingLevel {
        guard required > 0 else { return .full }
        
        let percentage = Double(current) / Double(required)
        
        if percentage >= 1.0 {
            return .full
        } else if percentage >= 0.8 {
            return .ok
        } else if percentage >= 0.5 {
            return .low
        } else {
            return .critical
        }
    }
}
