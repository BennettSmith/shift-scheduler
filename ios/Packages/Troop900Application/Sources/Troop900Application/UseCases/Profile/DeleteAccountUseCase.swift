import Foundation
import Troop900Domain

/// Protocol for deleting user account.
public protocol DeleteAccountUseCaseProtocol: Sendable {
    func checkEligibility(userId: String) async throws -> DeleteAccountEligibilityResponse
    func execute(request: DeleteAccountRequest) async throws
}

/// Use case for soft-deleting a user's account.
/// Used by UC 47 for users to remove themselves from the system.
/// This is a soft delete - account is marked inactive but data is retained.
public final class DeleteAccountUseCase: DeleteAccountUseCaseProtocol, Sendable {
    private let userRepository: UserRepository
    private let assignmentRepository: AssignmentRepository
    private let householdRepository: HouseholdRepository
    
    public init(
        userRepository: UserRepository,
        assignmentRepository: AssignmentRepository,
        householdRepository: HouseholdRepository
    ) {
        self.userRepository = userRepository
        self.assignmentRepository = assignmentRepository
        self.householdRepository = householdRepository
    }
    
    public func checkEligibility(userId: String) async throws -> DeleteAccountEligibilityResponse {
        // Validate and convert boundary ID to domain ID type
        let userIdValue = try UserId(userId)
        
        // Get user
        let user = try await userRepository.getUser(id: userIdValue)
        
        var blockers: [String] = []
        var futureAssignmentsCount = 0
        let hasActiveRoles = user.role.isLeadership
        
        // Check for future assignments
        let assignments = try await assignmentRepository.getAssignmentsForUser(userId: userIdValue)
        let futureAssignments = assignments.filter { assignment in
            assignment.isActive // Would ideally check shift date
        }
        futureAssignmentsCount = futureAssignments.count
        
        // Blocker: Future shift assignments
        if futureAssignmentsCount > 0 {
            blockers.append("You have \(futureAssignmentsCount) upcoming shift assignment(s). Please cancel them first.")
        }
        
        // Blocker: Active leadership role
        if hasActiveRoles {
            blockers.append("You have an active leadership/committee role. Please contact an administrator.")
        }
        
        // Blocker: Household manager
        let managedHouseholds = try await householdRepository.getHouseholdsManagedByUser(userId: userIdValue)
        if !managedHouseholds.isEmpty {
            blockers.append("You manage \(managedHouseholds.count) household(s). Please transfer management first.")
        }
        
        let canDelete = blockers.isEmpty
        let dataRetentionWarning = """
        Your account will be deactivated and you will no longer be able to sign in. \
        However, historical shift records and attendance data will be retained for record-keeping purposes. \
        To request complete data removal, please contact an administrator.
        """
        
        return DeleteAccountEligibilityResponse(
            canDelete: canDelete,
            blockers: blockers,
            futureAssignments: futureAssignmentsCount,
            hasActiveRoles: hasActiveRoles,
            dataRetentionWarning: dataRetentionWarning
        )
    }
    
    public func execute(request: DeleteAccountRequest) async throws {
        // Validate and convert boundary ID to domain ID type
        let userIdValue = try UserId(request.userId)
        
        // Validate confirmation
        guard request.confirmed else {
            throw DomainError.invalidInput("Account deletion must be confirmed")
        }
        
        // Check eligibility
        let eligibility = try await checkEligibility(userId: request.userId)
        guard eligibility.canDelete else {
            let blockerMessage = eligibility.blockers.joined(separator: " ")
            throw DomainError.operationFailed("Cannot delete account: \(blockerMessage)")
        }
        
        // Get user
        let user = try await userRepository.getUser(id: userIdValue)
        
        // Soft delete: Mark account as inactive
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            accountStatus: .inactive, // Mark as inactive
            households: user.households,
            canManageHouseholds: [],  // Remove management rights
            familyUnitId: user.familyUnitId,
            isClaimed: user.isClaimed,
            claimCode: nil,  // Clear claim code
            householdLinkCode: nil,  // Clear household link code
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        try await userRepository.updateUser(updatedUser)
        
        // Note: In a real implementation, we might also:
        // 1. Revoke authentication tokens
        // 2. Send confirmation email
        // 3. Log deletion for audit purposes
        // 4. Notify household members if applicable
    }
}
