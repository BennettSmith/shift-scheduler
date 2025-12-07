import Foundation
import Troop900Domain

/// Response containing a week's schedule organized by day.
public struct WeekScheduleResponse: Sendable, Equatable {
    public let weekStartDate: Date
    public let weekEndDate: Date
    public let days: [DaySchedule]
    
    public init(weekStartDate: Date, weekEndDate: Date, days: [DaySchedule]) {
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.days = days
    }
}

/// A single day's schedule with its shifts.
public struct DaySchedule: Sendable, Equatable, Identifiable {
    public let id: String
    public let date: Date
    public let shifts: [ShiftSummary]
    
    public init(id: String, date: Date, shifts: [ShiftSummary]) {
        self.id = id
        self.date = date
        self.shifts = shifts
    }
}
