import Foundation
import Troop900Domain

/// Protocol for getting a week's schedule.
public protocol GetWeekScheduleUseCaseProtocol: Sendable {
    func execute(request: WeekScheduleRequest) async throws -> WeekScheduleResponse
}

/// Use case for retrieving a week's schedule of shifts.
public final class GetWeekScheduleUseCase: GetWeekScheduleUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    
    public init(shiftRepository: ShiftRepository) {
        self.shiftRepository = shiftRepository
    }
    
    public func execute(request: WeekScheduleRequest) async throws -> WeekScheduleResponse {
        let calendar = Calendar.current
        
        // Calculate week start (Sunday) and end (Saturday)
        let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: request.referenceDate))!
        let weekEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate)!
        
        // Fetch shifts for the week
        let shifts = try await shiftRepository.getShiftsForDateRange(start: weekStartDate, end: weekEndDate)
        
        // Group shifts by day
        var daySchedules: [DaySchedule] = []
        for dayOffset in 0...6 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate)!
            let dayShifts = shifts.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            let shiftSummaries = dayShifts.map { shift in
                ShiftSummary(
                    id: shift.id,
                    date: shift.date,
                    startTime: shift.startTime,
                    endTime: shift.endTime,
                    requiredScouts: shift.requiredScouts,
                    requiredParents: shift.requiredParents,
                    currentScouts: shift.currentScouts,
                    currentParents: shift.currentParents,
                    location: shift.location,
                    label: shift.label,
                    status: shift.status,
                    staffingStatus: shift.staffingStatus,
                    timeRange: formatTimeRange(start: shift.startTime, end: shift.endTime)
                )
            }
            
            daySchedules.append(DaySchedule(
                id: "\(date.timeIntervalSince1970)",
                date: date,
                shifts: shiftSummaries
            ))
        }
        
        return WeekScheduleResponse(
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            days: daySchedules
        )
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
