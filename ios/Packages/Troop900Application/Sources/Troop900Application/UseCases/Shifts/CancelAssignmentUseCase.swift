import Foundation
import Troop900Domain

/// Protocol for canceling an assignment.
public protocol CancelAssignmentUseCaseProtocol: Sendable {
    func execute(request: CancelAssignmentRequest) async throws
}

/// Use case for canceling a shift assignment.
public final class CancelAssignmentUseCase: CancelAssignmentUseCaseProtocol, Sendable {
    private let assignmentRepository: AssignmentRepository
    private let shiftRepository: ShiftRepository
    private let shiftSignupService: ShiftSignupService
    
    public init(
        assignmentRepository: AssignmentRepository,
        shiftRepository: ShiftRepository,
        shiftSignupService: ShiftSignupService
    ) {
        self.assignmentRepository = assignmentRepository
        self.shiftRepository = shiftRepository
        self.shiftSignupService = shiftSignupService
    }
    
    public func execute(request: CancelAssignmentRequest) async throws {
        // Validate and convert boundary ID to domain ID type
        let assignmentId = try AssignmentId(request.assignmentId)
        
        // Validate assignment exists
        let assignment = try await assignmentRepository.getAssignment(id: assignmentId)
        
        guard assignment.isActive else {
            throw DomainError.assignmentNotActive
        }
        
        // Validate shift is in the future
        let shift = try await shiftRepository.getShift(id: assignment.shiftId)
        
        guard shift.startTime > Date() else {
            throw DomainError.cannotCancelAssignment
        }
        
        // Call service to cancel (Cloud Function handles transaction)
        try await shiftSignupService.cancelAssignment(
            assignmentId: assignmentId,
            reason: request.reason
        )
    }
}
