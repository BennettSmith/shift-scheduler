import Foundation
import Troop900Domain

/// Protocol for getting prioritized staffing alerts.
public protocol GetStaffingAlertsUseCaseProtocol: Sendable {
    func execute(daysAhead: Int, requestingUserId: String) async throws -> StaffingAlertsResponse
}

/// Use case for retrieving prioritized list of understaffed shifts.
/// Used by UC 42 for committee to identify shifts needing attention.
public final class GetStaffingAlertsUseCase: GetStaffingAlertsUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let userRepository: UserRepository
    
    public init(
        shiftRepository: ShiftRepository,
        userRepository: UserRepository
    ) {
        self.shiftRepository = shiftRepository
        self.userRepository = userRepository
    }
    
    public func execute(daysAhead: Int, requestingUserId: String) async throws -> StaffingAlertsResponse {
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate date range
        let startDate = calendar.startOfDay(for: now)
        let endDate = calendar.date(byAdding: .day, value: daysAhead, to: startDate)!
        
        // Fetch shifts for the date range
        let shifts = try await shiftRepository.getShiftsForDateRange(start: startDate, end: endDate)
        
        // Filter to only published shifts (no draft shifts)
        let publishedShifts = shifts.filter { $0.status == .published }
        
        var criticalAlerts: [StaffingAlert] = []
        var lowStaffingAlerts: [StaffingAlert] = []
        
        for shift in publishedShifts {
            // Calculate staffing levels
            let scoutLevel = StaffingLevel.calculate(
                current: shift.currentScouts,
                required: shift.requiredScouts
            )
            let parentLevel = StaffingLevel.calculate(
                current: shift.currentParents,
                required: shift.requiredParents
            )
            
            // Overall staffing is the worst of scout or parent staffing
            let overallLevel = min(scoutLevel.priority, parentLevel.priority) == scoutLevel.priority ? scoutLevel : parentLevel
            
            // Only create alerts for critical or low staffing
            guard overallLevel == .critical || overallLevel == .low else {
                continue
            }
            
            let scoutShortfall = max(0, shift.requiredScouts - shift.currentScouts)
            let parentShortfall = max(0, shift.requiredParents - shift.currentParents)
            let totalOpenSlots = scoutShortfall + parentShortfall
            
            // Calculate days until shift
            let daysUntil = calendar.dateComponents([.day], from: now, to: shift.date).day ?? 0
            
            let alert = StaffingAlert(
                id: shift.id,
                shiftId: shift.id,
                shiftDate: shift.date,
                shiftLabel: shift.label,
                timeRange: formatTimeRange(start: shift.startTime, end: shift.endTime),
                location: shift.location,
                staffingLevel: overallLevel,
                requiredScouts: shift.requiredScouts,
                currentScouts: shift.currentScouts,
                scoutShortfall: scoutShortfall,
                requiredParents: shift.requiredParents,
                currentParents: shift.currentParents,
                parentShortfall: parentShortfall,
                totalOpenSlots: totalOpenSlots,
                daysUntilShift: daysUntil
            )
            
            if overallLevel == .critical {
                criticalAlerts.append(alert)
            } else {
                lowStaffingAlerts.append(alert)
            }
        }
        
        // Sort alerts by priority: critical first, then by days until shift
        criticalAlerts.sort { $0.daysUntilShift < $1.daysUntilShift }
        lowStaffingAlerts.sort { $0.daysUntilShift < $1.daysUntilShift }
        
        return StaffingAlertsResponse(
            criticalAlerts: criticalAlerts,
            lowStaffingAlerts: lowStaffingAlerts,
            totalAlerts: criticalAlerts.count + lowStaffingAlerts.count,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
