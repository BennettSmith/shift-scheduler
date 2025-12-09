import Foundation
import Troop900Domain

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
        // Validate and convert boundary IDs to domain ID types
        let shiftIdValue = try ShiftId(shiftId)
        let userIdValue = try userId.map { try UserId($0) }
        
        let shift = try await shiftRepository.getShift(id: shiftIdValue)
        let assignments = try await assignmentRepository.getAssignmentsForShift(shiftId: shiftIdValue)
        
        // Build assignment info with user names
        var assignmentInfos: [AssignmentInfo] = []
        for assignment in assignments where assignment.isActive {
            if let user = try? await userRepository.getUser(id: assignment.userId) {
                assignmentInfos.append(AssignmentInfo(from: assignment, userName: user.fullName))
            }
        }
        
        // Find user's assignment if userId provided
        let userAssignment = userIdValue.flatMap { uid in
            assignmentInfos.first { $0.userId == uid.value }
        }
        
        // Determine if user can sign up or cancel
        let canSignUp = userIdValue != nil && shift.status.canAcceptSignups && userAssignment == nil &&
                        (shift.needsScouts || shift.needsParents)
        let canCancel = userAssignment != nil
        
        return ShiftDetailResponse(
            shift: ShiftDetail(from: shift),
            assignments: assignmentInfos,
            canSignUp: canSignUp,
            canCancel: canCancel,
            userAssignment: userAssignment
        )
    }
}
