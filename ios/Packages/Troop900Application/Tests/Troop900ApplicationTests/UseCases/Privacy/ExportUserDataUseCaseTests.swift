import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("ExportUserDataUseCase Tests")
struct ExportUserDataUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockUserRepository = MockUserRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockHouseholdRepository = MockHouseholdRepository()
    
    private var useCase: ExportUserDataUseCase {
        ExportUserDataUseCase(
            userRepository: mockUserRepository,
            assignmentRepository: mockAssignmentRepository,
            attendanceRepository: mockAttendanceRepository,
            householdRepository: mockHouseholdRepository
        )
    }
    
    // MARK: - Permission Tests
    
    @Test("Export own data succeeds for regular user")
    func exportOwnDataSucceeds() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId, firstName: "John", lastName: "Doe")
        mockUserRepository.usersById[userId] = user
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId, // Self export
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.userDataExport.profile.userId == userId)
        #expect(response.userDataExport.profile.firstName == "John")
        #expect(response.userDataExport.profile.lastName == "Doe")
    }
    
    @Test("Export other user data succeeds for admin")
    func exportOtherUserDataSucceedsForAdmin() async throws {
        // Given
        let adminId = "admin-1"
        let userId = "user-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        let user = TestFixtures.createParent(id: userId)
        
        mockUserRepository.usersById[adminId] = admin
        mockUserRepository.usersById[userId] = user
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: adminId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.userDataExport.profile.userId == userId)
    }
    
    @Test("Export other user data fails for non-admin")
    func exportOtherUserDataFailsForNonAdmin() async throws {
        // Given
        let parentId = "parent-1"
        let otherUserId = "user-2"
        let parent = TestFixtures.createParent(id: parentId)
        let otherUser = TestFixtures.createParent(id: otherUserId)
        
        mockUserRepository.usersById[parentId] = parent
        mockUserRepository.usersById[otherUserId] = otherUser
        
        let request = ExportUserDataRequest(
            userId: otherUserId,
            requestingUserId: parentId, // Non-admin trying to export another user's data
            format: .json,
            includeSoftDeleted: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Data Export Tests
    
    @Test("Export includes profile information")
    func exportIncludesProfile() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createUser(
            id: userId,
            email: "john@example.com",
            firstName: "John",
            lastName: "Doe",
            role: .parent,
            accountStatus: .active
        )
        mockUserRepository.usersById[userId] = user
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        let profile = response.userDataExport.profile
        #expect(profile.email == "john@example.com")
        #expect(profile.role == "parent")
        #expect(profile.accountStatus == "active")
    }
    
    @Test("Export includes household memberships")
    func exportIncludesHouseholds() async throws {
        // Given
        let userId = "user-1"
        let householdId = "household-1"
        let user = TestFixtures.createUser(
            id: userId,
            role: .parent,
            households: [householdId],
            canManageHouseholds: [householdId]
        )
        let household = TestFixtures.createHousehold(id: householdId, name: "Smith Family")
        
        mockUserRepository.usersById[userId] = user
        mockHouseholdRepository.householdsById[householdId] = household
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.userDataExport.households.count == 1)
        #expect(response.userDataExport.households[0].householdName == "Smith Family")
        #expect(response.userDataExport.households[0].role == "manager")
    }
    
    @Test("Export includes assignments")
    func exportIncludesAssignments() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let assignment1 = TestFixtures.createAssignment(id: "a1", userId: userId, status: .confirmed)
        let assignment2 = TestFixtures.createAssignment(id: "a2", userId: userId, status: .completed)
        mockAssignmentRepository.getAssignmentsForUserResult = .success([assignment1, assignment2])
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.userDataExport.assignments.count == 2)
    }
    
    @Test("Export includes attendance records")
    func exportIncludesAttendanceRecords() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let record1 = TestFixtures.createCompletedRecord(id: "r1", userId: userId, hoursWorked: 4.0)
        let record2 = TestFixtures.createCompletedRecord(id: "r2", userId: userId, hoursWorked: 3.0)
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record1, record2])
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.userDataExport.attendanceRecords.count == 2)
    }
    
    @Test("Export includes metadata with record count")
    func exportIncludesMetadata() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let assignment = TestFixtures.createAssignment(userId: userId)
        let record = TestFixtures.createCompletedRecord(userId: userId)
        mockAssignmentRepository.getAssignmentsForUserResult = .success([assignment])
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .success([record])
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.userDataExport.metadata.totalRecords == 3) // 1 profile + 1 assignment + 1 attendance
        #expect(response.userDataExport.metadata.exportVersion == "1.0")
    }
    
    @Test("Export calculates size in bytes")
    func exportCalculatesSize() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.sizeInBytes > 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Export fails when requesting user not found")
    func exportFailsWhenRequestingUserNotFound() async throws {
        // Given - no requesting user
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId)
        mockUserRepository.usersById[userId] = user
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: "non-existent",
            format: .json,
            includeSoftDeleted: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Export fails when target user not found")
    func exportFailsWhenTargetUserNotFound() async throws {
        // Given
        let adminId = "admin-1"
        let admin = TestFixtures.createCommittee(id: adminId)
        mockUserRepository.usersById[adminId] = admin
        
        let request = ExportUserDataRequest(
            userId: "non-existent",
            requestingUserId: adminId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Export handles missing households gracefully")
    func exportHandlesMissingHouseholds() async throws {
        // Given
        let userId = "user-1"
        let user = TestFixtures.createUser(
            id: userId,
            role: .parent,
            households: ["missing-household-1", "missing-household-2"]
        )
        mockUserRepository.usersById[userId] = user
        // No households in repository
        
        let request = ExportUserDataRequest(
            userId: userId,
            requestingUserId: userId,
            format: .json,
            includeSoftDeleted: false
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then - should succeed with empty households
        #expect(response.userDataExport.households.isEmpty)
    }
}
