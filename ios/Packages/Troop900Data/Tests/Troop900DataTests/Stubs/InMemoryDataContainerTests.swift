import Foundation
import Testing
@testable import Troop900Data
import Troop900Domain

@Suite("InMemoryDataContainer Tests")
struct InMemoryDataContainerTests {
    
    @Test("Container initializes with empty data")
    func containerInitializesEmpty() {
        let container = InMemoryDataContainer()
        
        #expect(container.userRepository != nil)
        #expect(container.shiftRepository != nil)
        #expect(container.attendanceService != nil)
        #expect(container.shiftSignupService != nil)
    }
    
    @Test("Container initializes with initial data")
    func containerInitializesWithData() async throws {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let container = InMemoryDataContainer(initialUsers: [user])
        
        let retrieved = try await container.userRepository.getUser(id: user.id)
        #expect(retrieved == user)
    }
    
    @Test("Services are properly wired with repositories")
    func servicesWiredCorrectly() async throws {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let shift = Shift(
            id: ShiftId(unchecked: "shift-1"),
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            requiredScouts: 3,
            requiredParents: 2,
            currentScouts: 0,
            currentParents: 0,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: nil,
            templateId: nil,
            createdAt: Date()
        )
        
        let assignment = Assignment(
            id: AssignmentId(unchecked: "assignment-1"),
            shiftId: shift.id,
            userId: user.id,
            assignmentType: .scout,
            status: .confirmed,
            notes: nil,
            assignedAt: Date(),
            assignedBy: nil
        )
        
        let container = InMemoryDataContainer(
            initialUsers: [user],
            initialShifts: [shift],
            initialAssignments: [assignment]
        )
        
        // Verify services can access repositories
        let retrievedUser = try await container.userRepository.getUser(id: user.id)
        #expect(retrievedUser == user)
        
        let retrievedShift = try await container.shiftRepository.getShift(id: shift.id)
        #expect(retrievedShift == shift)
    }
    
    @Test("Clear all removes all data")
    func clearAll() async throws {
        let user = User(
            id: UserId(unchecked: "user-1"),
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .scout,
            accountStatus: .active,
            households: [],
            canManageHouseholds: [],
            familyUnitId: nil,
            isClaimed: true,
            claimCode: nil,
            householdLinkCode: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let container = InMemoryDataContainer(initialUsers: [user])
        
        container.clearAll()
        
        do {
            _ = try await container.userRepository.getUser(id: user.id)
            Issue.record("Expected DomainError.userNotFound")
        } catch DomainError.userNotFound {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
