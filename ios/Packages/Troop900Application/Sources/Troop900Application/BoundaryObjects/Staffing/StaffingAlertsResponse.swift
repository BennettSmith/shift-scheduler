import Foundation

/// Response containing prioritized list of understaffed shifts.
public struct StaffingAlertsResponse: Sendable, Equatable {
    /// Shifts that are critically understaffed
    public let criticalAlerts: [StaffingAlert]
    
    /// Shifts that have low staffing
    public let lowStaffingAlerts: [StaffingAlert]
    
    /// Total number of alerts
    public let totalAlerts: Int
    
    /// Date range covered by alerts
    public let startDate: Date
    public let endDate: Date
    
    public init(
        criticalAlerts: [StaffingAlert],
        lowStaffingAlerts: [StaffingAlert],
        totalAlerts: Int,
        startDate: Date,
        endDate: Date
    ) {
        self.criticalAlerts = criticalAlerts
        self.lowStaffingAlerts = lowStaffingAlerts
        self.totalAlerts = totalAlerts
        self.startDate = startDate
        self.endDate = endDate
    }
}
