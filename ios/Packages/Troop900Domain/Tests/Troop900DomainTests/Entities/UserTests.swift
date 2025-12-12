import Foundation
import Testing
@testable import Troop900Domain

@Suite("User Tests")
struct UserTests {
    
    @Test("User initialization")
    func userInitialization() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: ["household-1"],
            canManageHouseholds: [],
            familyUnitId: "family-1",
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(user.id.value == "user-1")
        #expect(user.email == "test@example.com")
        #expect(user.firstName == "John")
        #expect(user.lastName == "Doe")
        #expect(user.role == UserRole.scout)
    }
    
    @Test("Full name is computed correctly")
    func fullName() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(user.fullName == "John Doe")
    }
    
    @Test("Scoutmaster is admin")
    func scoutmasterIsAdmin() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scoutmaster,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(user.isAdmin)
    }
    
    @Test("Assistant Scoutmaster is admin")
    func assistantScoutmasterIsAdmin() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.assistantScoutmaster,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(user.isAdmin)
    }
    
    @Test("Scout is not admin")
    func scoutIsNotAdmin() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(!user.isAdmin)
    }
    
    @Test("Active and claimed user can sign up for shifts")
    func activeClaimedCanSignUp() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(user.canSignUpForShifts)
    }
    
    @Test("Inactive user cannot sign up for shifts")
    func inactiveUserCannotSignUp() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.inactive,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(!user.canSignUpForShifts)
    }
    
    @Test("Unclaimed user cannot sign up for shifts")
    func unclaimedUserCannotSignUp() {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: false,
            claimCode: "CLAIM123",
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        #expect(!user.canSignUpForShifts)
    }
    
    @Test("User equality")
    func userEquality() {
        let date = Date()
        let user1 = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: date,
            updatedAt: date
        )
        
        let user2 = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: UserRole.scout,
            accountStatus: AccountStatus.active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: date,
            updatedAt: date
        )
        
        #expect(user1 == user2)
    }
}
