import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetMyShiftsUseCase Tests")
struct GetMyShiftsUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockShiftRepository = MockShiftRepository()
    
    private var useCase: GetMyShiftsUseCase {
        GetMyShiftsUseCase(
            assignmentRepository: mockAssignmentRepository,
            shiftRepository: mockShiftRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get my shifts returns empty list when no assignments")
    func getMyShiftsReturnsEmptyWhenNoAssignments() async throws {
        // Given
        let userId = "user-1"
        // No assignments in repository
        
        // When
        let shifts = try await useCase.execute(userId: userId)
        
        // Then
        #expect(shifts.isEmpty)
        #expect(mockAssignmentRepository.getAssignmentsForUserCallCount == 1)
        #expect(mockAssignmentRepository.getAssignmentsForUserCalledWith[0] == userId)
    }
    
    @Test("Get my shifts returns user's assigned shifts")
    func getMyShiftsReturnsAssignedShifts() async throws {
        // Given
        let userId = "user-1"
        let shift1 = TestFixtures.createShift(
            id: "shift-1",
            date: DateTestHelpers.tomorrow,
            label: "Morning Shift"
        )
        let shift2 = TestFixtures.createShift(
            id: "shift-2",
            date: DateTestHelpers.tomorrow.addingDays(1),
            label: "Afternoon Shift"
        )
        let assignment1 = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: userId,
            status: .confirmed
        )
        let assignment2 = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: "shift-2",
            userId: userId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById["shift-1"] = shift1
        mockShiftRepository.shiftsById["shift-2"] = shift2
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment1
        mockAssignmentRepository.assignmentsById["assignment-2"] = assignment2
        
        // When
        let shifts = try await useCase.execute(userId: userId)
        
        // Then
        #expect(shifts.count == 2)
    }
    
    @Test("Get my shifts only includes active assignments")
    func getMyShiftsOnlyIncludesActiveAssignments() async throws {
        // Given
        let userId = "user-1"
        let shift1 = TestFixtures.createShift(id: "shift-1", label: "Active")
        let shift2 = TestFixtures.createShift(id: "shift-2", label: "Cancelled")
        let activeAssignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: userId,
            status: .confirmed
        )
        let cancelledAssignment = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: "shift-2",
            userId: userId,
            status: .cancelled
        )
        
        mockShiftRepository.shiftsById["shift-1"] = shift1
        mockShiftRepository.shiftsById["shift-2"] = shift2
        mockAssignmentRepository.assignmentsById["assignment-1"] = activeAssignment
        mockAssignmentRepository.assignmentsById["assignment-2"] = cancelledAssignment
        
        // When
        let shifts = try await useCase.execute(userId: userId)
        
        // Then
        #expect(shifts.count == 1)
        #expect(shifts[0].id == "shift-1")
    }
    
    @Test("Get my shifts sorts by start time")
    func getMyShiftsSortsByStartTime() async throws {
        // Given
        let userId = "user-1"
        let laterDate = DateTestHelpers.tomorrow.addingDays(2)
        let earlierDate = DateTestHelpers.tomorrow
        
        let laterShift = TestFixtures.createShift(
            id: "later-shift",
            date: laterDate,
            startTime: laterDate.addingHours(9)
        )
        let earlierShift = TestFixtures.createShift(
            id: "earlier-shift",
            date: earlierDate,
            startTime: earlierDate.addingHours(9)
        )
        
        // Add assignments (later one first to test sorting)
        let assignment1 = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: "later-shift",
            userId: userId,
            status: .confirmed
        )
        let assignment2 = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: "earlier-shift",
            userId: userId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById["later-shift"] = laterShift
        mockShiftRepository.shiftsById["earlier-shift"] = earlierShift
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment1
        mockAssignmentRepository.assignmentsById["assignment-2"] = assignment2
        
        // When
        let shifts = try await useCase.execute(userId: userId)
        
        // Then
        #expect(shifts.count == 2)
        #expect(shifts[0].id == "earlier-shift")
        #expect(shifts[1].id == "later-shift")
    }
    
    @Test("Get my shifts includes shift summary with time range")
    func getMyShiftsIncludesTimeRange() async throws {
        // Given
        let userId = "user-1"
        let shiftDate = DateTestHelpers.tomorrow
        let shift = TestFixtures.createShift(
            id: "shift-1",
            date: shiftDate,
            startTime: shiftDate.addingHours(9),
            endTime: shiftDate.addingHours(13)
        )
        let assignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: "shift-1",
            userId: userId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById["shift-1"] = shift
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignment
        
        // When
        let shifts = try await useCase.execute(userId: userId)
        
        // Then
        #expect(shifts.count == 1)
        #expect(shifts[0].timeRange.isEmpty == false)
    }
    
    @Test("Get my shifts handles missing shift gracefully")
    func getMyShiftsHandlesMissingShiftGracefully() async throws {
        // Given
        let userId = "user-1"
        let existingShift = TestFixtures.createShift(id: "existing-shift")
        let assignmentToExisting = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: "existing-shift",
            userId: userId,
            status: .confirmed
        )
        let assignmentToMissing = TestFixtures.createAssignment(
            id: "assignment-2",
            shiftId: "missing-shift",
            userId: userId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById["existing-shift"] = existingShift
        // "missing-shift" is not in repository
        mockAssignmentRepository.assignmentsById["assignment-1"] = assignmentToExisting
        mockAssignmentRepository.assignmentsById["assignment-2"] = assignmentToMissing
        
        // When
        let shifts = try await useCase.execute(userId: userId)
        
        // Then - should only return the shift that exists
        #expect(shifts.count == 1)
        #expect(shifts[0].id == "existing-shift")
    }
    
    // MARK: - Error Tests
    
    @Test("Get my shifts propagates assignment repository error")
    func getMyShiftsPropagatesAssignmentError() async throws {
        // Given
        mockAssignmentRepository.getAssignmentsForUserResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(userId: "user-1")
        }
    }
}
