import Foundation
import Troop900Domain

/// Simulated implementation of FamilyManagementService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedFamilyManagementService: FamilyManagementService, @unchecked Sendable {
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    private let familyUnitRepository: FamilyUnitRepository
    private let lock = AsyncLock()
    
    public init(
        userRepository: UserRepository,
        householdRepository: HouseholdRepository,
        familyUnitRepository: FamilyUnitRepository
    ) {
        self.userRepository = userRepository
        self.householdRepository = householdRepository
        self.familyUnitRepository = familyUnitRepository
    }
    
    public func addFamilyMember(request: AddFamilyMemberRequest) async throws -> AddFamilyMemberResult {
        // Verify household exists
        let household = try await householdRepository.getHousehold(id: request.householdId)
        
        // Create user
        let userId = try UserId(unchecked: UUID().uuidString)
        let claimCode = UUID().uuidString
        
        let user = User(
            id: userId,
            email: request.email,
            firstName: request.firstName,
            lastName: request.lastName,
            role: request.role,
            accountStatus: .pending,
            households: [request.householdId],
            canManageHouseholds: [],
            familyUnitId: request.familyUnitId,
            isClaimed: false,
            claimCode: claimCode,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await userRepository.createUser(user)
        
        // Update household members
        var updatedMembers = household.members
        updatedMembers.append(userId.value)
        
        let updatedHousehold = Household(
            id: household.id,
            name: household.name,
            members: updatedMembers,
            managers: household.managers,
            familyUnits: household.familyUnits,
            linkCode: household.linkCode,
            isActive: household.isActive,
            createdAt: household.createdAt,
            updatedAt: Date()
        )
        
        try await householdRepository.updateHousehold(updatedHousehold)
        
        // Update family unit if provided
        if let familyUnitId = request.familyUnitId {
            let familyUnit = try await familyUnitRepository.getFamilyUnit(id: familyUnitId)
            var updatedScouts = familyUnit.scouts
            var updatedParents = familyUnit.parents
            
            if request.role == .scout {
                updatedScouts.append(userId.value)
            } else {
                updatedParents.append(userId.value)
            }
            
            let updatedFamilyUnit = FamilyUnit(
                id: familyUnit.id,
                householdId: familyUnit.householdId,
                scouts: updatedScouts,
                parents: updatedParents,
                name: familyUnit.name,
                createdAt: familyUnit.createdAt
            )
            
            try await familyUnitRepository.updateFamilyUnit(updatedFamilyUnit)
        }
        
        return AddFamilyMemberResult(
            success: true,
            userId: userId,
            claimCode: claimCode,
            message: "Family member added successfully"
        )
    }
    
    public func linkScoutToHousehold(scoutId: UserId, linkCode: String) async throws -> LinkScoutResult {
        // Find household by link code
        guard let household = try await householdRepository.getHouseholdByLinkCode(linkCode: linkCode) else {
            return LinkScoutResult(
                success: false,
                householdId: nil,
                message: "Invalid link code"
            )
        }
        
        // Get scout user
        let scout = try await userRepository.getUser(id: scoutId)
        
        // Update user's households
        var households = scout.households
        if !households.contains(household.id) {
            households.append(household.id)
        }
        
        let updatedUser = User(
            id: scout.id,
            email: scout.email,
            firstName: scout.firstName,
            lastName: scout.lastName,
            role: scout.role,
            accountStatus: scout.accountStatus,
            households: households,
            canManageHouseholds: scout.canManageHouseholds,
            familyUnitId: scout.familyUnitId,
            isClaimed: scout.isClaimed,
            claimCode: scout.claimCode,
            householdLinkCode: linkCode,
            createdAt: scout.createdAt,
            updatedAt: Date()
        )
        
        try await userRepository.updateUser(updatedUser)
        
        // Update household members
        var updatedMembers = household.members
        if !updatedMembers.contains(scoutId.value) {
            updatedMembers.append(scoutId.value)
        }
        
        let updatedHousehold = Household(
            id: household.id,
            name: household.name,
            members: updatedMembers,
            managers: household.managers,
            familyUnits: household.familyUnits,
            linkCode: household.linkCode,
            isActive: household.isActive,
            createdAt: household.createdAt,
            updatedAt: Date()
        )
        
        try await householdRepository.updateHousehold(updatedHousehold)
        
        return LinkScoutResult(
            success: true,
            householdId: household.id,
            message: "Scout linked to household successfully"
        )
    }
    
    public func regenerateHouseholdLinkCode(householdId: String) async throws -> String {
        let household = try await householdRepository.getHousehold(id: householdId)
        let newLinkCode = UUID().uuidString
        
        let updatedHousehold = Household(
            id: household.id,
            name: household.name,
            members: household.members,
            managers: household.managers,
            familyUnits: household.familyUnits,
            linkCode: newLinkCode,
            isActive: household.isActive,
            createdAt: household.createdAt,
            updatedAt: Date()
        )
        
        try await householdRepository.updateHousehold(updatedHousehold)
        
        return newLinkCode
    }
    
    public func deactivateFamily(request: FamilyDeactivationRequest) async throws {
        let user = try await userRepository.getUser(id: request.userId)
        
        // Update user account status
        let updatedUser = User(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
            accountStatus: .deactivated,
            households: user.households,
            canManageHouseholds: user.canManageHouseholds,
            familyUnitId: user.familyUnitId,
            isClaimed: user.isClaimed,
            claimCode: user.claimCode,
            householdLinkCode: user.householdLinkCode,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        try await userRepository.updateUser(updatedUser)
    }
}
