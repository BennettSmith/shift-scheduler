import Foundation

/// Response containing a week's schedule with enhanced staffing indicators.
public struct WeekScheduleWithStaffingResponse: Sendable, Equatable {
    public let weekStartDate: Date
    public let weekEndDate: Date
    public let days: [DayStaffingSchedule]
    
    // Week-level statistics
    public let totalShifts: Int
    public let criticalShifts: Int
    public let lowStaffingShifts: Int
    public let fullyStaffedShifts: Int
    
    public init(
        weekStartDate: Date,
        weekEndDate: Date,
        days: [DayStaffingSchedule],
        totalShifts: Int,
        criticalShifts: Int,
        lowStaffingShifts: Int,
        fullyStaffedShifts: Int
    ) {
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.days = days
        self.totalShifts = totalShifts
        self.criticalShifts = criticalShifts
        self.lowStaffingShifts = lowStaffingShifts
        self.fullyStaffedShifts = fullyStaffedShifts
    }
}

/// A single day's schedule with staffing indicators.
public struct DayStaffingSchedule: Sendable, Equatable, Identifiable {
    public let id: String
    public let date: Date
    public let shifts: [ShiftStaffingSummary]
    
    public init(id: String, date: Date, shifts: [ShiftStaffingSummary]) {
        self.id = id
        self.date = date
        self.shifts = shifts
    }
}
