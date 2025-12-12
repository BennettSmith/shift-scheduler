import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("SimulatedOnboardingService Tests")
struct SimulatedOnboardingServiceTests {
    
    func makeTestUser(isClaimed: Bool = false) -> User {
        User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: isClaimed ? .active : .pending,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: isClaimed,
            claimCode: isClaimed ? nil : "CLAIM123",
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func makeTestInviteCode(isUsed: Bool = false, isExpired: Bool = false) -> InviteCode {
        InviteCode(
            id: "invite-1",
            code: "INVITE123",
            householdId: "household-1",
            role: .scout,
            createdBy: "admin-1",
            usedBy: isUsed ? "user-2" : nil,
            usedAt: isUsed ? Date() : nil,
            expiresAt: isExpired ? Date().addingTimeInterval(-86400) : Date().addingTimeInterval(86400),
            isUsed: isUsed,
            createdAt: Date()
        )
    }
    
    func makeTestHousehold() -> Household {
        Household(
            id: "household-1",
            name: "Test Household",
            members: [],
            managers: [],
            familyUnits: [],
            linkCode: nil,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    @Test("Process invite code successfully")
    func processInviteCode() async throws {
        let user = makeTestUser()
        let inviteCode = makeTestInviteCode()
        let household = makeTestHousehold()
        
        let inviteRepo = InMemoryInviteCodeRepository(initialInviteCodes: [inviteCode])
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let householdRepo = InMemoryHouseholdRepository(initialHouseholds: [household])
        
        let service = SimulatedOnboardingService(
            inviteCodeRepository: inviteRepo,
            userRepository: userRepo,
            householdRepository: householdRepo
        )
        
        let result = try await service.processInviteCode(code: "INVITE123", userId: user.id)
        
        #expect(result.success)
        #expect(result.householdId == "household-1")
        #expect(result.userRole == .scout)
        
        // Verify user was updated
        let updatedUser = try await userRepo.getUser(id: user.id)
        #expect(updatedUser.households.contains("household-1"))
        
        // Verify invite code was marked as used
        let updatedInvite = try await inviteRepo.getInviteCodeByCode(code: "INVITE123")
        #expect(updatedInvite?.isUsed == true)
    }
    
    @Test("Process invite code fails when code not found")
    func processInviteCodeNotFound() async throws {
        let user = makeTestUser()
        let inviteRepo = InMemoryInviteCodeRepository()
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let householdRepo = InMemoryHouseholdRepository()
        
        let service = SimulatedOnboardingService(
            inviteCodeRepository: inviteRepo,
            userRepository: userRepo,
            householdRepository: householdRepo
        )
        
        let result = try await service.processInviteCode(code: "INVALID", userId: user.id)
        
        #expect(!result.success)
        #expect(result.householdId == nil)
    }
    
    @Test("Process invite code fails when already used")
    func processInviteCodeAlreadyUsed() async throws {
        let user = makeTestUser()
        let inviteCode = makeTestInviteCode(isUsed: true)
        
        let inviteRepo = InMemoryInviteCodeRepository(initialInviteCodes: [inviteCode])
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let householdRepo = InMemoryHouseholdRepository()
        
        let service = SimulatedOnboardingService(
            inviteCodeRepository: inviteRepo,
            userRepository: userRepo,
            householdRepository: householdRepo
        )
        
        let result = try await service.processInviteCode(code: "INVITE123", userId: user.id)
        
        #expect(!result.success)
    }
    
    @Test("Claim profile successfully")
    func claimProfile() async throws {
        let user = makeTestUser(isClaimed: false)
        
        let inviteRepo = InMemoryInviteCodeRepository()
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let householdRepo = InMemoryHouseholdRepository()
        
        let service = SimulatedOnboardingService(
            inviteCodeRepository: inviteRepo,
            userRepository: userRepo,
            householdRepository: householdRepo
        )
        
        let result = try await service.claimProfile(claimCode: "CLAIM123", userId: user.id)
        
        #expect(result.success)
        #expect(result.userId == user.id)
        
        // Verify user was updated
        let updatedUser = try await userRepo.getUser(id: user.id)
        #expect(updatedUser.isClaimed == true)
        #expect(updatedUser.accountStatus == .active)
    }
    
    @Test("Claim profile fails when code not found")
    func claimProfileNotFound() async throws {
        let user = makeTestUser()
        let inviteRepo = InMemoryInviteCodeRepository()
        let userRepo = InMemoryUserRepository(initialUsers: [user])
        let householdRepo = InMemoryHouseholdRepository()
        
        let service = SimulatedOnboardingService(
            inviteCodeRepository: inviteRepo,
            userRepository: userRepo,
            householdRepository: householdRepo
        )
        
        let result = try await service.claimProfile(claimCode: "INVALID", userId: user.id)
        
        #expect(!result.success)
    }
}
