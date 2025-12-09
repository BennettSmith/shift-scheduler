import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("CancelAssignmentUseCase Tests")
struct CancelAssignmentUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockShiftRepository = MockShiftRepository()
    private let mockShiftSignupService = MockShiftSignupService()
    
    private var useCase: CancelAssignmentUseCase {
        CancelAssignmentUseCase(
            assignmentRepository: mockAssignmentRepository,
            shiftRepository: mockShiftRepository,
            shiftSignupService: mockShiftSignupService
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Cancel assignment succeeds for future shift")
    func cancelAssignmentSucceedsForFutureShift() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        let futureShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            startTime: DateTestHelpers.tomorrow.addingHours(9),
            status: .published
        )
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = futureShift
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = CancelAssignmentRequest(
            assignmentId: assignmentId,
            reason: "Schedule conflict"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockShiftSignupService.cancelAssignmentCallCount == 1)
        #expect(mockShiftSignupService.cancelAssignmentCalledWith[0].assignmentId.value == assignmentId)
        #expect(mockShiftSignupService.cancelAssignmentCalledWith[0].reason == "Schedule conflict")
    }
    
    @Test("Cancel assignment succeeds without reason")
    func cancelAssignmentSucceedsWithoutReason() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        let futureShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            startTime: DateTestHelpers.tomorrow.addingHours(9),
            status: .published
        )
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = futureShift
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = CancelAssignmentRequest(
            assignmentId: assignmentId,
            reason: nil
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockShiftSignupService.cancelAssignmentCallCount == 1)
        #expect(mockShiftSignupService.cancelAssignmentCalledWith[0].reason == nil)
    }
    
    // MARK: - Assignment Validation Tests
    
    @Test("Cancel fails when assignment not found")
    func cancelFailsWhenAssignmentNotFound() async throws {
        // Given
        let request = CancelAssignmentRequest(
            assignmentId: "non-existent",
            reason: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.cancelAssignmentCallCount == 0)
    }
    
    @Test("Cancel fails when assignment is not active")
    func cancelFailsWhenAssignmentNotActive() async throws {
        // Given
        let assignmentId = "assignment-1"
        let cancelledAssignment = TestFixtures.createAssignment(
            id: assignmentId,
            status: .cancelled
        )
        
        mockAssignmentRepository.assignmentsById[assignmentId] = cancelledAssignment
        
        let request = CancelAssignmentRequest(
            assignmentId: assignmentId,
            reason: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.cancelAssignmentCallCount == 0)
    }
    
    // MARK: - Shift Validation Tests
    
    @Test("Cancel fails when shift has already started")
    func cancelFailsWhenShiftStarted() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        
        // Create a shift that started in the past
        let now = Date()
        let pastStartTime = now.addingTimeInterval(-3600) // 1 hour ago
        let shiftInProgress = Shift(
            id: ShiftId(unchecked: shiftId),
            date: now.startOfDay,
            startTime: pastStartTime,
            endTime: now.addingTimeInterval(7200), // 2 hours from now
            requiredScouts: 4,
            requiredParents: 2,
            currentScouts: 2,
            currentParents: 1,
            location: "Tree Lot",
            label: nil,
            notes: nil,
            status: .published,
            seasonId: "season-1",
            templateId: nil,
            createdAt: Date()
        )
        
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shiftInProgress
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = CancelAssignmentRequest(
            assignmentId: assignmentId,
            reason: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.cancelAssignmentCallCount == 0)
    }
    
    // MARK: - Service Error Tests
    
    @Test("Cancel propagates service error")
    func cancelPropagatesServiceError() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        let futureShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            startTime: DateTestHelpers.tomorrow.addingHours(9),
            status: .published
        )
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = futureShift
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockShiftSignupService.cancelAssignmentError = DomainError.networkError
        
        let request = CancelAssignmentRequest(
            assignmentId: assignmentId,
            reason: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.cancelAssignmentCallCount == 1)
    }
}
