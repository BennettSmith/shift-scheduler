import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("PermanentlyDeleteUserDataUseCase Tests")
struct PermanentlyDeleteUserDataUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockUserRepository = MockUserRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockHouseholdRepository = MockHouseholdRepository()
    
    private var useCase: PermanentlyDeleteUserDataUseCase {
        PermanentlyDeleteUserDataUseCase(
            userRepository: mockUserRepository,
            assignmentRepository: mockAssignmentRepository,
            attendanceRepository: mockAttendanceRepository,
            householdRepository: mockHouseholdRepository
        )
    }
    
    // MARK: - Permission Tests
    
    @Test("Permanent delete succeeds for admin")
    func permanentDeleteSucceedsForAdmin() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([])
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: "TICKET-123"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.deletedRecords.userProfile == 1)
    }
    
    @Test("Permanent delete fails for non-admin")
    func permanentDeleteFailsForNonAdmin() async throws {
        // Given
        let parentId = "parent-1"
        let userId = "user-1"
        let parent = TestFixtures.createParent(id: parentId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[parentId] = parent
        mockUserRepository.usersById[userId] = user
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: parentId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Validation Tests
    
    @Test("Permanent delete fails without confirmation")
    func permanentDeleteFailsWithoutConfirmation() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: false, // Not confirmed
            userRequestReference: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Permanent delete fails for active account")
    func permanentDeleteFailsForActiveAccount() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .active) // Not inactive
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Deletion Tests
    
    @Test("Permanent delete removes assignments")
    func permanentDeleteRemovesAssignments() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        
        let assignment1 = TestFixtures.createAssignment(id: "a1", userId: userId)
        let assignment2 = TestFixtures.createAssignment(id: "a2", userId: userId)
        mockAssignmentRepository.getAssignmentsForUserResult = .success([assignment1, assignment2])
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([])
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.deletedRecords.assignments == 2)
        #expect(mockAssignmentRepository.deleteAssignmentCallCount == 2)
    }
    
    @Test("Permanent delete counts attendance records")
    func permanentDeleteCountsAttendanceRecords() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        
        let record1 = TestFixtures.createCompletedRecord(id: "r1", userId: userId)
        let record2 = TestFixtures.createCompletedRecord(id: "r2", userId: userId)
        let record3 = TestFixtures.createCompletedRecord(id: "r3", userId: userId)
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record1, record2, record3])
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.deletedRecords.attendanceRecords == 3)
    }
    
    @Test("Permanent delete removes user from households")
    func permanentDeleteRemovesFromHouseholds() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let householdId = "household-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(
            id: userId,
            role: .parent,
            accountStatus: .inactive,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        let household = TestFixtures.createHousehold(
            id: householdId,
            members: [userId, "other-user"],
            managers: [userId]
        )
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        mockHouseholdRepository.householdsById[householdId] = household
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([])
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When
        _ = try await useCase.execute(request: request)
        
        // Then
        #expect(mockHouseholdRepository.updateHouseholdCallCount == 1)
        let updatedHousehold = mockHouseholdRepository.updateHouseholdCalledWith[0]
        #expect(!updatedHousehold.members.contains(userId))
        #expect(!updatedHousehold.managers.contains(userId))
        #expect(updatedHousehold.members.contains("other-user"))
    }
    
    @Test("Permanent delete returns audit log ID")
    func permanentDeleteReturnsAuditLogId() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.getAssignmentsForUserResult = .success([])
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([])
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(!response.auditLogId.isEmpty)
    }
    
    @Test("Permanent delete returns total record count in message")
    func permanentDeleteReturnsTotalCount() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        
        let assignment = TestFixtures.createAssignment(userId: userId)
        let record = TestFixtures.createCompletedRecord(userId: userId)
        mockAssignmentRepository.getAssignmentsForUserResult = .success([assignment])
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record])
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        let total = response.deletedRecords.total
        #expect(total == 3) // 1 profile + 1 assignment + 1 attendance
        #expect(response.message.contains("\(total)"))
    }
    
    // MARK: - Error Tests
    
    @Test("Permanent delete fails when admin not found")
    func permanentDeleteFailsWhenAdminNotFound() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createUser(id: userId, role: .parent, accountStatus: .inactive)
        mockUserRepository.usersById[userId] = user
        
        let request = PermanentDeleteRequest(
            userId: userId,
            adminUserId: "non-existent",
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Permanent delete fails when user not found")
    func permanentDeleteFailsWhenUserNotFound() async throws {
        // Given
        let adminId = "admin-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        mockUserRepository.usersById[adminId] = admin
        
        let request = PermanentDeleteRequest(
            userId: "non-existent",
            adminUserId: adminId,
            reason: "GDPR request",
            confirmed: true,
            userRequestReference: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
