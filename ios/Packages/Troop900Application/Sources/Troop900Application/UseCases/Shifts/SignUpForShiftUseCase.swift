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
        // Validate shift exists and is available
        let shift = try await shiftRepository.getShift(id: request.shiftId)
        
        guard shift.status.canAcceptSignups else {
            throw DomainError.shiftNotPublished
        }
        
        guard shift.date > Date() else {
            throw DomainError.shiftInPast
        }
        
        // Validate user can sign up
        let user = try await userRepository.getUser(id: request.userId)
        
        guard user.canSignUpForShifts else {
            throw DomainError.userAccountInactive
        }
        
        // Check if user is already assigned
        let existingAssignments = try await assignmentRepository.getAssignmentsForShift(shiftId: request.shiftId)
        if existingAssignments.contains(where: { $0.userId == request.userId && $0.isActive }) {
            throw DomainError.alreadyAssignedToShift
        }
        
        // Check if shift has space for the assignment type
        switch request.assignmentType {
        case .scout where !shift.needsScouts:
            throw DomainError.shiftFull
        case .parent where !shift.needsParents:
            throw DomainError.shiftFull
        default:
            break
        }
        
        // Call service to sign up (Cloud Function handles transaction)
        let serviceRequest = ShiftSignupServiceRequest(
            shiftId: request.shiftId,
            userId: request.userId,
            assignmentType: request.assignmentType,
            notes: request.notes
        )
        
        let serviceResponse = try await shiftSignupService.signUp(request: serviceRequest)
        
        return SignUpForShiftResponse(
            success: serviceResponse.success,
            assignmentId: serviceResponse.assignmentId,
            message: serviceResponse.message
        )
    }
}
