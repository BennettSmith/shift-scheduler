import Foundation
import Troop900Domain

/// Simulated implementation of OnboardingService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedOnboardingService: OnboardingService, @unchecked Sendable {
    private let inviteCodeRepository: InviteCodeRepository
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    private let lock = AsyncLock()
    
    public init(
        inviteCodeRepository: InviteCodeRepository,
        userRepository: UserRepository,
        householdRepository: HouseholdRepository
    ) {
        self.inviteCodeRepository = inviteCodeRepository
        self.userRepository = userRepository
        self.householdRepository = householdRepository
    }
    
    public func processInviteCode(code: String, userId: UserId) async throws -> InviteCodeResult {
        // Find invite code
        guard let inviteCode = try await inviteCodeRepository.getInviteCodeByCode(code: code) else {
            return InviteCodeResult(
                success: false,
                householdId: nil,
                userRole: nil,
                message: "Invite code not found"
            )
        }
        
        // Check if already used
        if inviteCode.isUsed {
            return InviteCodeResult(
                success: false,
                householdId: nil,
                userRole: nil,
                message: "Invite code already used"
            )
        }
        
        // Check if expired
        if inviteCode.isExpired {
            return InviteCodeResult(
                success: false,
                householdId: nil,
                userRole: nil,
                message: "Invite code has expired"
            )
        }
        
        // Get user and update with household and role
        var user = try await userRepository.getUser(id: userId)
        var households = user.households
        if !households.contains(inviteCode.householdId) {
            households.append(inviteCode.householdId)
        }
        
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: inviteCode.role,
            accountStatus: user.accountStatus,
            households: households,
            canManageHouseholds: user.canManageHouseholds,
            familyUnitId: user.familyUnitId,
            isClaimed: user.isClaimed,
            claimCode: user.claimCode,
            householdLinkCode: user.householdLinkCode,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        try await userRepository.updateUser(updatedUser)
        
        // Mark invite code as used
        let updatedInviteCode = InviteCode(
            id: inviteCode.id,
            code: inviteCode.code,
            householdId: inviteCode.householdId,
            role: inviteCode.role,
            createdBy: inviteCode.createdBy,
            usedBy: userId.value,
            usedAt: Date(),
            expiresAt: inviteCode.expiresAt,
            isUsed: true,
            createdAt: inviteCode.createdAt
        )
        
        try await inviteCodeRepository.updateInviteCode(updatedInviteCode)
        
        return InviteCodeResult(
            success: true,
            householdId: inviteCode.householdId,
            userRole: inviteCode.role,
            message: "Successfully joined household"
        )
    }
    
    public func claimProfile(claimCode: String, userId: UserId) async throws -> ClaimProfileResult {
        // Find user by claim code
        guard let user = try await userRepository.getUserByClaimCode(code: claimCode) else {
            return ClaimProfileResult(
                success: false,
                userId: nil,
                message: "Claim code not found"
            )
        }
        
        // Check if already claimed
        if user.isClaimed {
            return ClaimProfileResult(
                success: false,
                userId: nil,
                message: "Profile already claimed"
            )
        }
        
        // Update user to claimed status
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            accountStatus: .active,
            households: user.households,
            canManageHouseholds: user.canManageHouseholds,
            familyUnitId: user.familyUnitId,
            isClaimed: true,
            claimCode: user.claimCode,
            householdLinkCode: user.householdLinkCode,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        try await userRepository.updateUser(updatedUser)
        
        return ClaimProfileResult(
            success: true,
            userId: user.id,
            message: "Profile successfully claimed"
        )
    }
}
