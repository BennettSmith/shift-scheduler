import Foundation

/// Staffing level type for boundary objects.
/// This is a simple data carrier with no behavior - business logic
/// for calculating staffing levels lives in the Domain layer.
public enum StaffingLevelType: String, Sendable, Equatable, Codable {
    case critical
    case low
    case ok
    case full
}
