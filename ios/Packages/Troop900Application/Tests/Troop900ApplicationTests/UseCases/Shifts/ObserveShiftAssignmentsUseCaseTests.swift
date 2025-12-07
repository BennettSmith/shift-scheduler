import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("ObserveShiftAssignmentsUseCase Tests")
struct ObserveShiftAssignmentsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: ObserveShiftAssignmentsUseCase {
        ObserveShiftAssignmentsUseCase(
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Stream Tests
    
    @Test("Observe assignments returns stream with assignment info")
    func observeAssignmentsReturnsStream() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let user = TestFixtures.createParent(id: userId, firstName: "John", lastName: "Doe")
        let assignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            status: .confirmed
        )
        
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment
        
        // When
        let stream = useCase.execute(shiftId: shiftId)
        
        // Then
        var receivedAssignments: [AssignmentInfo]?
        for try await value in stream {
            receivedAssignments = value
            break
        }
        
        #expect(receivedAssignments != nil)
        #expect(receivedAssignments?.count == 1)
        #expect(receivedAssignments?[0].userId == userId)
        #expect(receivedAssignments?[0].userName == "John Doe")
        #expect(receivedAssignments?[0].assignmentType == .parent)
    }
    
    @Test("Observe assignments excludes inactive assignments")
    func observeAssignmentsExcludesInactive() async throws {
        // Given
        let shiftId = "shift-1"
        let user1 = TestFixtures.createParent(id: "user-1")
        let user2 = TestFixtures.createParent(id: "user-2")
        
        let activeAssignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: "user-1",
            status: .confirmed
        )
        let cancelledAssignment = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: shiftId,
            userId: "user-2",
            status: .cancelled
        )
        
        mockUserRepository.usersById["user-1"] = user1
        mockUserRepository.usersById["user-2"] = user2
        mockAssignmentRepository.assignmentsById["assignment-1"] = activeAssignment
        mockAssignmentRepository.assignmentsById["assignment-2"] = cancelledAssignment
        
        // When
        let stream = useCase.execute(shiftId: shiftId)
        
        // Then
        var receivedAssignments: [AssignmentInfo]?
        for try await value in stream {
            receivedAssignments = value
            break
        }
        
        #expect(receivedAssignments?.count == 1)
        #expect(receivedAssignments?[0].userId == "user-1")
    }
    
    @Test("Observe assignments handles missing user gracefully")
    func observeAssignmentsHandlesMissingUser() async throws {
        // Given
        let shiftId = "shift-1"
        let assignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: "missing-user",
            status: .confirmed
        )
        
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment
        // User not in repository
        
        // When
        let stream = useCase.execute(shiftId: shiftId)
        
        // Then - assignment should be skipped
        var receivedAssignments: [AssignmentInfo]?
        for try await value in stream {
            receivedAssignments = value
            break
        }
        
        #expect(receivedAssignments?.isEmpty == true)
    }
    
    @Test("Observe assignments returns empty list when no assignments")
    func observeAssignmentsReturnsEmptyWhenNoAssignments() async throws {
        // Given
        let shiftId = "shift-1"
        // No assignments in repository
        
        // When
        let stream = useCase.execute(shiftId: shiftId)
        
        // Then
        var receivedAssignments: [AssignmentInfo]?
        for try await value in stream {
            receivedAssignments = value
            break
        }
        
        #expect(receivedAssignments?.isEmpty == true)
    }
}
