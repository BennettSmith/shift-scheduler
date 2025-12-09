import Foundation
import Troop900Domain

/// Protocol for getting a week's schedule with enhanced staffing indicators.
public protocol GetWeekScheduleWithStaffingUseCaseProtocol: Sendable {
    func execute(request: WeekScheduleRequest, requestingUserId: String) async throws -> WeekScheduleWithStaffingResponse
}

/// Use case for retrieving a week's schedule with detailed staffing indicators.
/// Used by UC 41 for committee to view staffing levels at a glance.
public final class GetWeekScheduleWithStaffingUseCase: GetWeekScheduleWithStaffingUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let userRepository: UserRepository
    
    public init(
        shiftRepository: ShiftRepository,
        userRepository: UserRepository
    ) {
        self.shiftRepository = shiftRepository
        self.userRepository = userRepository
    }
    
    public func execute(request: WeekScheduleRequest, requestingUserId: String) async throws -> WeekScheduleWithStaffingResponse {
        // Validate and convert boundary ID to domain ID type
        let requestingUserIdValue = try UserId(requestingUserId)
        
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserIdValue)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        let calendar = Calendar.current
        
        // Calculate week start (Sunday) and end (Saturday)
        let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: request.referenceDate))!
        let weekEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate)!
        
        // Fetch shifts for the week
        let shifts = try await shiftRepository.getShiftsForDateRange(start: weekStartDate, end: weekEndDate)
        
        // Track week-level statistics
        var totalShifts = 0
        var criticalShifts = 0
        var lowStaffingShifts = 0
        var fullyStaffedShifts = 0
        
        // Group shifts by day
        var daySchedules: [DayStaffingSchedule] = []
        for dayOffset in 0...6 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate)!
            let dayShifts = shifts.filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            let shiftSummaries = dayShifts.map { shift in
                // Calculate staffing levels using domain StaffingLevel
                let scoutLevel = StaffingLevel(
                    current: shift.currentScouts,
                    required: shift.requiredScouts
                )
                let parentLevel = StaffingLevel(
                    current: shift.currentParents,
                    required: shift.requiredParents
                )
                
                // Overall staffing is the worst of scout or parent staffing
                let overallLevel = scoutLevel.priority <= parentLevel.priority ? scoutLevel : parentLevel
                
                let openSlots = (shift.requiredScouts - shift.currentScouts) + (shift.requiredParents - shift.currentParents)
                
                // Update statistics
                totalShifts += 1
                switch overallLevel {
                case .critical:
                    criticalShifts += 1
                case .low:
                    lowStaffingShifts += 1
                case .full:
                    fullyStaffedShifts += 1
                case .ok:
                    break
                }
                
                // Convert domain StaffingLevel to boundary StaffingLevelType
                return ShiftStaffingSummary(
                    id: shift.id.value,
                    date: shift.date,
                    startTime: shift.startTime,
                    endTime: shift.endTime,
                    location: shift.location,
                    label: shift.label,
                    status: ShiftStatusType(from: shift.status),
                    timeRange: formatTimeRange(start: shift.startTime, end: shift.endTime),
                    requiredScouts: shift.requiredScouts,
                    currentScouts: shift.currentScouts,
                    scoutStaffingLevel: StaffingLevelType(from: scoutLevel),
                    requiredParents: shift.requiredParents,
                    currentParents: shift.currentParents,
                    parentStaffingLevel: StaffingLevelType(from: parentLevel),
                    overallStaffingLevel: StaffingLevelType(from: overallLevel),
                    openSlots: openSlots
                )
            }
            
            daySchedules.append(DayStaffingSchedule(
                id: "\(date.timeIntervalSince1970)",
                date: date,
                shifts: shiftSummaries
            ))
        }
        
        return WeekScheduleWithStaffingResponse(
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            days: daySchedules,
            totalShifts: totalShifts,
            criticalShifts: criticalShifts,
            lowStaffingShifts: lowStaffingShifts,
            fullyStaffedShifts: fullyStaffedShifts
        )
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
