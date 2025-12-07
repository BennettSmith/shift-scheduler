import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetShiftDetailsUseCase Tests")
struct GetShiftDetailsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: GetShiftDetailsUseCase {
        GetShiftDetailsUseCase(
            shiftRepository: mockShiftRepository,
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get shift details succeeds with no assignments")
    func getShiftDetailsSucceedsWithNoAssignments() async throws {
        // Given
        let shiftId = "shift-1"
        let shift = TestFixtures.createShift(id: shiftId, status: .published)
        mockShiftRepository.shiftsById[shiftId] = shift
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: nil)
        
        // Then
        #expect(response.shift.id == shiftId)
        #expect(response.assignments.isEmpty)
        #expect(response.canSignUp == false) // No userId provided
        #expect(response.canCancel == false)
        #expect(response.userAssignment == nil)
    }
    
    @Test("Get shift details succeeds with assignments")
    func getShiftDetailsSucceedsWithAssignments() async throws {
        // Given
        let shiftId = "shift-1"
        let userId1 = "user-1"
        let userId2 = "user-2"
        
        let shift = TestFixtures.createShift(id: shiftId, status: .published)
        let user1 = TestFixtures.createParent(id: userId1, firstName: "John", lastName: "Doe")
        let user2 = TestFixtures.createScout(id: userId2, firstName: "Jane", lastName: "Doe")
        let assignment1 = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: userId1,
            assignmentType: .parent,
            status: .confirmed
        )
        let assignment2 = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: shiftId,
            userId: userId2,
            assignmentType: .scout,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId1] = user1
        mockUserRepository.usersById[userId2] = user2
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment1
        mockAssignmentRepository.assignmentsById["assignment-2"] = assignment2
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: nil)
        
        // Then
        #expect(response.assignments.count == 2)
    }
    
    @Test("Get shift details shows user can sign up when not assigned")
    func getShiftDetailsShowsUserCanSignUp() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        
        let shift = TestFixtures.createShift(
            id: shiftId,
            requiredScouts: 4,
            currentScouts: 2, // Has openings
            status: .published
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: userId)
        
        // Then
        #expect(response.canSignUp == true)
        #expect(response.canCancel == false)
        #expect(response.userAssignment == nil)
    }
    
    @Test("Get shift details shows user can cancel when assigned")
    func getShiftDetailsShowsUserCanCancel() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        
        let shift = TestFixtures.createShift(id: shiftId, status: .published)
        let user = TestFixtures.createParent(id: userId, firstName: "John", lastName: "Doe")
        let assignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: userId)
        
        // Then
        #expect(response.canSignUp == false) // Already assigned
        #expect(response.canCancel == true)
        #expect(response.userAssignment != nil)
        #expect(response.userAssignment?.userId == userId)
    }
    
    @Test("Get shift details shows cannot sign up when shift is full")
    func getShiftDetailsShowsCannotSignUpWhenFull() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        
        let fullShift = TestFixtures.createFullShift(id: shiftId)
        mockShiftRepository.shiftsById[shiftId] = fullShift
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: userId)
        
        // Then
        #expect(response.canSignUp == false) // Shift is full
    }
    
    @Test("Get shift details shows cannot sign up when not published")
    func getShiftDetailsShowsCannotSignUpWhenDraft() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        
        let draftShift = TestFixtures.createDraftShift(id: shiftId)
        mockShiftRepository.shiftsById[shiftId] = draftShift
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: userId)
        
        // Then
        #expect(response.canSignUp == false) // Draft status
    }
    
    @Test("Get shift details excludes inactive assignments")
    func getShiftDetailsExcludesInactiveAssignments() async throws {
        // Given
        let shiftId = "shift-1"
        let userId1 = "user-1"
        let userId2 = "user-2"
        
        let shift = TestFixtures.createShift(id: shiftId, status: .published)
        let user1 = TestFixtures.createParent(id: userId1)
        let user2 = TestFixtures.createParent(id: userId2)
        let activeAssignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: userId1,
            status: .confirmed
        )
        let cancelledAssignment = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: shiftId,
            userId: userId2,
            status: .cancelled
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId1] = user1
        mockUserRepository.usersById[userId2] = user2
        mockAssignmentRepository.assignmentsById["assignment-1"] = activeAssignment
        mockAssignmentRepository.assignmentsById["assignment-2"] = cancelledAssignment
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: nil)
        
        // Then
        #expect(response.assignments.count == 1) // Only active assignment
        #expect(response.assignments[0].userId == userId1)
    }
    
    // MARK: - Error Tests
    
    @Test("Get shift details fails when shift not found")
    func getShiftDetailsFailsWhenNotFound() async throws {
        // Given - no shift in repository
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(shiftId: "non-existent", userId: nil)
        }
    }
    
    @Test("Get shift details handles missing user gracefully")
    func getShiftDetailsHandlesMissingUser() async throws {
        // Given
        let shiftId = "shift-1"
        let shift = TestFixtures.createShift(id: shiftId, status: .published)
        let assignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: "missing-user",
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment
        // User not in repository
        
        // When
        let response = try await useCase.execute(shiftId: shiftId, userId: nil)
        
        // Then - assignment should be skipped if user not found
        #expect(response.assignments.isEmpty)
    }
}
