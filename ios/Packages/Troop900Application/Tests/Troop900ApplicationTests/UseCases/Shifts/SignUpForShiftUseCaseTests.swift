import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("SignUpForShiftUseCase Tests")
struct SignUpForShiftUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockUserRepository = MockUserRepository()
    private let mockShiftSignupService = MockShiftSignupService()
    
    private var useCase: SignUpForShiftUseCase {
        SignUpForShiftUseCase(
            shiftRepository: mockShiftRepository,
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository,
            shiftSignupService: mockShiftSignupService
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Sign up succeeds for scout with available slot")
    func signUpSucceedsForScout() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            requiredScouts: 4,
            currentScouts: 2,
            status: .published
        )
        let user = TestFixtures.createScout(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId] = user
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .scout,
            notes: "First time volunteering"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.assignmentId.isEmpty == false)
        #expect(mockShiftSignupService.signUpCallCount == 1)
        #expect(mockShiftSignupService.signUpCalledWith[0].shiftId.value == shiftId)
        #expect(mockShiftSignupService.signUpCalledWith[0].userId.value == userId)
        #expect(mockShiftSignupService.signUpCalledWith[0].assignmentType == .scout)
    }
    
    @Test("Sign up succeeds for parent with available slot")
    func signUpSucceedsForParent() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            requiredParents: 2,
            currentParents: 1,
            status: .published
        )
        let user = TestFixtures.createParent(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId] = user
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(mockShiftSignupService.signUpCallCount == 1)
    }
    
    // MARK: - Shift Validation Tests
    
    @Test("Sign up fails when shift is not published")
    func signUpFailsWhenShiftNotPublished() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let draftShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            status: .draft
        )
        let user = TestFixtures.createParent(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = draftShift
        mockUserRepository.usersById[userId] = user
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 0)
    }
    
    @Test("Sign up fails when shift is in the past")
    func signUpFailsWhenShiftInPast() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let pastShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.yesterday,
            status: .published
        )
        let user = TestFixtures.createParent(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = pastShift
        mockUserRepository.usersById[userId] = user
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 0)
    }
    
    @Test("Sign up fails when shift not found")
    func signUpFailsWhenShiftNotFound() async throws {
        // Given
        let request = SignUpForShiftRequest(
            shiftId: "non-existent",
            userId: "user-1",
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - User Validation Tests
    
    @Test("Sign up fails when user account is inactive")
    func signUpFailsWhenUserInactive() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            status: .published
        )
        let inactiveUser = TestFixtures.createUser(
            id: userId,
            accountStatus: .inactive
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId] = inactiveUser
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 0)
    }
    
    @Test("Sign up fails when user not found")
    func signUpFailsWhenUserNotFound() async throws {
        // Given
        let shiftId = "shift-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            status: .published
        )
        mockShiftRepository.shiftsById[shiftId] = shift
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: "non-existent-user",
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Assignment Validation Tests
    
    @Test("Sign up fails when user already assigned to shift")
    func signUpFailsWhenAlreadyAssigned() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            status: .published
        )
        let user = TestFixtures.createParent(id: userId)
        let existingAssignment = TestFixtures.createAssignment(
            id: "assignment-1",
            shiftId: shiftId,
            userId: userId,
            status: .confirmed
        )
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId] = user
        mockAssignmentRepository.assignmentsById["assignment-1"] = existingAssignment
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 0)
    }
    
    @Test("Sign up fails when scout slots are full")
    func signUpFailsWhenScoutSlotsFull() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let fullShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            requiredScouts: 4,
            currentScouts: 4, // Full
            status: .published
        )
        let user = TestFixtures.createScout(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = fullShift
        mockUserRepository.usersById[userId] = user
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .scout,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 0)
    }
    
    @Test("Sign up fails when parent slots are full")
    func signUpFailsWhenParentSlotsFull() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let fullShift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            requiredParents: 2,
            currentParents: 2, // Full
            status: .published
        )
        let user = TestFixtures.createParent(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = fullShift
        mockUserRepository.usersById[userId] = user
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 0)
    }
    
    // MARK: - Service Error Tests
    
    @Test("Sign up propagates service error")
    func signUpPropagatesServiceError() async throws {
        // Given
        let shiftId = "shift-1"
        let userId = "user-1"
        let shift = TestFixtures.createShift(
            id: shiftId,
            date: DateTestHelpers.tomorrow,
            status: .published
        )
        let user = TestFixtures.createParent(id: userId)
        
        mockShiftRepository.shiftsById[shiftId] = shift
        mockUserRepository.usersById[userId] = user
        mockShiftSignupService.signUpResult = .failure(DomainError.networkError)
        
        let request = SignUpForShiftRequest(
            shiftId: shiftId,
            userId: userId,
            assignmentType: .parent,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockShiftSignupService.signUpCallCount == 1)
    }
}
