import Foundation
import Troop900Domain

// MARK: - StaffingLevelType Mapping

extension StaffingLevelType {
    /// Convert from domain StaffingLevel to boundary StaffingLevelType
    init(from domain: StaffingLevel) {
        switch domain {
        case .critical:
            self = .critical
        case .low:
            self = .low
        case .ok:
            self = .ok
        case .full:
            self = .full
        }
    }
}
