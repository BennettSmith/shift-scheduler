import Foundation
import Troop900Domain

/// Protocol for getting a user's shifts.
public protocol GetMyShiftsUseCaseProtocol: Sendable {
    func execute(userId: String) async throws -> [MyShiftAssignment]
}

/// Use case for retrieving all shifts assigned to a user.
/// Returns assignment info alongside shift info so users have the assignmentId
/// needed for check-in, check-out, and cancel operations.
public final class GetMyShiftsUseCase: GetMyShiftsUseCaseProtocol, Sendable {
    private let assignmentRepository: AssignmentRepository
    private let shiftRepository: ShiftRepository
    
    public init(assignmentRepository: AssignmentRepository, shiftRepository: ShiftRepository) {
        self.assignmentRepository = assignmentRepository
        self.shiftRepository = shiftRepository
    }
    
    public func execute(userId: String) async throws -> [MyShiftAssignment] {
        // Validate and convert boundary ID to domain ID type
        let userIdValue = try UserId(userId)
        
        // Get active assignments for user
        let assignments = try await assignmentRepository.getAssignmentsForUser(userId: userIdValue)
        let activeAssignments = assignments.filter { $0.isActive }
        
        // Fetch shifts for assignments and build MyShiftAssignment objects
        var myShiftAssignments: [MyShiftAssignment] = []
        let now = Date()
        
        for assignment in activeAssignments {
            guard let shift = try? await shiftRepository.getShift(id: assignment.shiftId) else {
                continue
            }
            
            // Determine if user can check in (shift is published and within check-in window)
            let canCheckIn = shift.status == .published &&
                             assignment.status == .confirmed &&
                             shift.startTime <= now.addingTimeInterval(30 * 60) // 30 min before start
            
            // Determine if user can cancel (shift hasn't started yet)
            let canCancel = assignment.status != .cancelled &&
                           shift.startTime > now
            
            let myShiftAssignment = MyShiftAssignment(
                id: assignment.id.value,
                assignmentType: AssignmentTypeValue(from: assignment.assignmentType),
                assignmentStatus: AssignmentStatusType(from: assignment.status),
                assignedAt: assignment.assignedAt,
                notes: assignment.notes,
                shiftId: shift.id.value,
                shiftDate: shift.date,
                startTime: shift.startTime,
                endTime: shift.endTime,
                location: shift.location,
                label: shift.label,
                shiftStatus: ShiftStatusType(from: shift.status),
                timeRange: formatTimeRange(start: shift.startTime, end: shift.endTime),
                canCheckIn: canCheckIn,
                canCancel: canCancel
            )
            
            myShiftAssignments.append(myShiftAssignment)
        }
        
        // Sort by start time
        return myShiftAssignments.sorted { $0.startTime < $1.startTime }
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
