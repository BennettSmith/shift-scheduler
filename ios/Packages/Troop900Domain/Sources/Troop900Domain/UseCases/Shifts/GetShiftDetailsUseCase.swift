import Foundation

/// Protocol for getting detailed shift information.
public protocol GetShiftDetailsUseCaseProtocol: Sendable {
    func execute(shiftId: String, userId: String?) async throws -> ShiftDetailResponse
}

/// Use case for retrieving detailed information about a specific shift.
public final class GetShiftDetailsUseCase: GetShiftDetailsUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let assignmentRepository: AssignmentRepository
    private let userRepository: UserRepository
    
    public init(
        shiftRepository: ShiftRepository,
        assignmentRepository: AssignmentRepository,
        userRepository: UserRepository
    ) {
        self.shiftRepository = shiftRepository
        self.assignmentRepository = assignmentRepository
        self.userRepository = userRepository
    }
    
    public func execute(shiftId: String, userId: String?) async throws -> ShiftDetailResponse {
        let shift = try await shiftRepository.getShift(id: shiftId)
        let assignments = try await assignmentRepository.getAssignmentsForShift(shiftId: shiftId)
        
        // Build assignment info with user names
        var assignmentInfos: [AssignmentInfo] = []
        for assignment in assignments where assignment.isActive {
            if let user = try? await userRepository.getUser(id: assignment.userId) {
                assignmentInfos.append(AssignmentInfo(
                    id: assignment.id,
                    userId: assignment.userId,
                    userName: user.fullName,
                    assignmentType: assignment.assignmentType,
                    status: assignment.status,
                    notes: assignment.notes,
                    assignedAt: assignment.assignedAt
                ))
            }
        }
        
        // Find user's assignment if userId provided
        let userAssignment = userId.flatMap { uid in
            assignmentInfos.first { $0.userId == uid }
        }
        
        // Determine if user can sign up or cancel
        let canSignUp = userId != nil && shift.status.canAcceptSignups && userAssignment == nil &&
                        (shift.needsScouts || shift.needsParents)
        let canCancel = userAssignment != nil
        
        return ShiftDetailResponse(
            shift: shift,
            assignments: assignmentInfos,
            canSignUp: canSignUp,
            canCancel: canCancel,
            userAssignment: userAssignment
        )
    }
}
