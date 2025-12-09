import Foundation
import Troop900Domain

/// Protocol for signing up for a shift.
public protocol SignUpForShiftUseCaseProtocol: Sendable {
    func execute(request: SignUpForShiftRequest) async throws -> SignUpForShiftResponse
}

/// Use case for signing up for a shift.
public final class SignUpForShiftUseCase: SignUpForShiftUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    private let shiftSignupService: ShiftSignupService
    
    public init(
        shiftRepository: ShiftRepository,
        assignmentRepository: AssignmentRepository,
        userRepository: UserRepository,
        shiftSignupService: ShiftSignupService
    ) {
        self.shiftRepository = shiftRepository
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
        self.shiftSignupService = shiftSignupService
    }
    
    public func execute(request: SignUpForShiftRequest) async throws -> SignUpForShiftResponse {
        // Validate and convert boundary IDs to domain ID types
        let shiftId = try ShiftId(request.shiftId)
        let userId = try UserId(request.userId)
        
        // Convert boundary type to domain type
        let assignmentType = request.assignmentType.toDomain()
        
        // Validate shift exists and is available
        let shift = try await shiftRepository.getShift(id: shiftId)
        
        guard shift.status.canAcceptSignups else {
            throw DomainError.shiftNotPublished
        }
        
        guard shift.date > Date() else {
            throw DomainError.shiftInPast
        }
        
        // Validate user can sign up
        let user = try await userRepository.getUser(id: userId)
        
        guard user.canSignUpForShifts else {
            throw DomainError.userAccountInactive
        }
        
        // Check if user is already assigned
        let existingAssignments = try await assignmentRepository.getAssignmentsForShift(shiftId: shiftId)
        if existingAssignments.contains(where: { $0.userId == userId && $0.isActive }) {
            throw DomainError.alreadyAssignedToShift
        }
        
        // Check if shift has space for the assignment type
        switch assignmentType {
        case .scout where !shift.needsScouts:
            throw DomainError.shiftFull
        case .parent where !shift.needsParents:
            throw DomainError.shiftFull
        case .scout, .parent:
            break // Has space
        }
        
        // Call service to sign up (Cloud Function handles transaction)
        let serviceRequest = ShiftSignupServiceRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: assignmentType,
            notes: request.notes
        )
        
        let serviceResponse = try await shiftSignupService.signUp(request: serviceRequest)
        
        return SignUpForShiftResponse(
            success: serviceResponse.success,
            assignmentId: serviceResponse.assignmentId.value,
            message: serviceResponse.message
        )
    }
}
