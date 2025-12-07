import Foundation

/// Protocol for getting a user's shifts.
public protocol GetMyShiftsUseCaseProtocol: Sendable {
    func execute(userId: String) async throws -> [ShiftSummary]
}

/// Use case for retrieving all shifts assigned to a user.
public final class GetMyShiftsUseCase: GetMyShiftsUseCaseProtocol, Sendable {
    private let assignmentRepository: AssignmentRepository
    private let shiftRepository: ShiftRepository
    
    public init(assignmentRepository: AssignmentRepository, shiftRepository: ShiftRepository) {
        self.assignmentRepository = assignmentRepository
        self.shiftRepository = shiftRepository
    }
    
    public func execute(userId: String) async throws -> [ShiftSummary] {
        // Get active assignments for user
        let assignments = try await assignmentRepository.getAssignmentsForUser(userId: userId)
        let activeAssignments = assignments.filter { $0.isActive }
        
        // Fetch shifts for assignments
        var shiftSummaries: [ShiftSummary] = []
        for assignment in activeAssignments {
            if let shift = try? await shiftRepository.getShift(id: assignment.shiftId) {
                shiftSummaries.append(ShiftSummary(
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
                ))
            }
        }
        
        // Sort by date
        return shiftSummaries.sorted { $0.startTime < $1.startTime }
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
