import Foundation
import Troop900Domain

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
        // Validate and convert boundary ID to domain ID type
        let userIdValue = try UserId(userId)
        
        // Get active assignments for user
        let assignments = try await assignmentRepository.getAssignmentsForUser(userId: userIdValue)
        let activeAssignments = assignments.filter { $0.isActive }
        
        // Fetch shifts for assignments
        var shiftSummaries: [ShiftSummary] = []
        for assignment in activeAssignments {
            if let shift = try? await shiftRepository.getShift(id: assignment.shiftId) {
                shiftSummaries.append(ShiftSummary(from: shift))
            }
        }
        
        // Sort by date
        return shiftSummaries.sorted { $0.startTime < $1.startTime }
    }
}
