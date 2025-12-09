import Foundation

/// Detailed staffing level indicator for committee visibility.
/// More granular than StaffingStatus to highlight critical understaffing.
///
/// Business rules for staffing thresholds:
/// - Critical: < 50% filled
/// - Low: 50-80% filled
/// - OK: 80-100% filled
/// - Full: 100% filled
public enum StaffingLevel: Sendable, Equatable {
    case critical
    case low
    case ok
    case full
    
    /// Initialize staffing level based on current vs required volunteers.
    /// This encapsulates the business rules for determining staffing adequacy.
    public init(current: Int, required: Int) {
        guard required > 0 else {
            self = .full
            return
        }
        
        let percentage = Double(current) / Double(required)
        
        if percentage >= 1.0 {
            self = .full
        } else if percentage >= 0.8 {
            self = .ok
        } else if percentage >= 0.5 {
            self = .low
        } else {
            self = .critical
        }
    }
    
    /// Priority for sorting/comparison. Lower values indicate more urgent staffing needs.
    /// This is a domain concept for ordering shifts by staffing urgency.
    public var priority: Int {
        switch self {
        case .critical: return 0
        case .low: return 1
        case .ok: return 2
        case .full: return 3
        }
    }
}
