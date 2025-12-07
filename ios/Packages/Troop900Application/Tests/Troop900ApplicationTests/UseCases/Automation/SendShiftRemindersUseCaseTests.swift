import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("SendShiftRemindersUseCase Tests")
struct SendShiftRemindersUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockShiftRepository = MockShiftRepository()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: SendShiftRemindersUseCase {
        SendShiftRemindersUseCase(
            shiftRepository: mockShiftRepository,
            assignmentRepository: mockAssignmentRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Basic Execution Tests
    
    @Test("Send reminders succeeds with no shifts")
    func sendRemindersSucceedsWithNoShifts() async throws {
        // Given
        mockShiftRepository.getShiftsForDateRangeResult = .success([])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.shiftsProcessed == 0)
        #expect(response.remindersSent == 0)
        #expect(response.failures == 0)
        #expect(response.reminders.isEmpty)
    }
    
    @Test("Send reminders processes only published shifts")
    func sendRemindersProcessesOnlyPublishedShifts() async throws {
        // Given
        let publishedShift = TestFixtures.createShift(id: "published", status: .published)
        let draftShift = TestFixtures.createShift(id: "draft", status: .draft)
        let completedShift = TestFixtures.createShift(id: "completed", status: .completed)
        
        mockShiftRepository.getShiftsForDateRangeResult = .success([publishedShift, draftShift, completedShift])
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.shiftsProcessed == 1) // Only published shift
    }
    
    @Test("Send reminders skips shifts with no assignments")
    func sendRemindersSkipsShiftsWithNoAssignments() async throws {
        // Given
        let shift = TestFixtures.createShift(id: "shift-1", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([]) // No assignments
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.shiftsProcessed == 1)
        #expect(response.remindersSent == 0)
        #expect(response.reminders.isEmpty) // No reminder entry for shift with no assignments
    }
    
    // MARK: - Reminder Sending Tests
    
    @Test("Send reminders sends to all assigned users")
    func sendRemindersSendsToAllUsers() async throws {
        // Given
        let shift = TestFixtures.createShift(id: "shift-1", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        let user1 = TestFixtures.createParent(id: "user-1")
        let user2 = TestFixtures.createScout(id: "user-2")
        let user3 = TestFixtures.createParent(id: "user-3")
        mockUserRepository.usersById["user-1"] = user1
        mockUserRepository.usersById["user-2"] = user2
        mockUserRepository.usersById["user-3"] = user3
        
        let assignment1 = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        let assignment2 = TestFixtures.createAssignment(id: "a2", shiftId: "shift-1", userId: "user-2", status: .confirmed)
        let assignment3 = TestFixtures.createAssignment(id: "a3", shiftId: "shift-1", userId: "user-3", status: .confirmed)
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([assignment1, assignment2, assignment3])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.remindersSent == 3)
        #expect(response.failures == 0)
        #expect(response.reminders.count == 1)
        #expect(response.reminders[0].recipientCount == 3)
        #expect(response.reminders[0].success == true)
    }
    
    @Test("Send reminders deduplicates users with multiple assignments")
    func sendRemindersDeduplicatesUsers() async throws {
        // Given
        let shift = TestFixtures.createShift(id: "shift-1", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        let user = TestFixtures.createParent(id: "user-1")
        mockUserRepository.usersById["user-1"] = user
        
        // Same user assigned twice (could happen if user is both scout and parent helper)
        let assignment1 = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        let assignment2 = TestFixtures.createAssignment(id: "a2", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([assignment1, assignment2])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.remindersSent == 1) // Only one reminder despite two assignments
        #expect(response.reminders[0].recipientCount == 1)
    }
    
    @Test("Send reminders excludes inactive assignments")
    func sendRemindersExcludesInactiveAssignments() async throws {
        // Given
        let shift = TestFixtures.createShift(id: "shift-1", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        let user1 = TestFixtures.createParent(id: "user-1")
        let user2 = TestFixtures.createParent(id: "user-2")
        mockUserRepository.usersById["user-1"] = user1
        mockUserRepository.usersById["user-2"] = user2
        
        let activeAssignment = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        let cancelledAssignment = TestFixtures.createAssignment(id: "a2", shiftId: "shift-1", userId: "user-2", status: .cancelled)
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([activeAssignment, cancelledAssignment])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.remindersSent == 1) // Only active assignment
        #expect(response.reminders[0].recipientCount == 1)
    }
    
    // MARK: - Multiple Shifts Tests
    
    @Test("Send reminders processes multiple shifts")
    func sendRemindersProcessesMultipleShifts() async throws {
        // Given
        let shift1 = TestFixtures.createShift(id: "shift-1", label: "Morning Shift", status: .published)
        let shift2 = TestFixtures.createShift(id: "shift-2", label: "Afternoon Shift", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift1, shift2])
        
        let user1 = TestFixtures.createParent(id: "user-1")
        let user2 = TestFixtures.createParent(id: "user-2")
        mockUserRepository.usersById["user-1"] = user1
        mockUserRepository.usersById["user-2"] = user2
        
        // Add assignments for each shift
        let assignment1 = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        let assignment2 = TestFixtures.createAssignment(id: "a2", shiftId: "shift-2", userId: "user-2", status: .confirmed)
        mockAssignmentRepository.assignmentsById["a1"] = assignment1
        mockAssignmentRepository.assignmentsById["a2"] = assignment2
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.shiftsProcessed == 2)
        #expect(response.remindersSent == 2)
        #expect(response.reminders.count == 2)
    }
    
    // MARK: - Failure Handling Tests
    
    @Test("Send reminders tracks failures when user not found")
    func sendRemindersTracksFailures() async throws {
        // Given
        let shift = TestFixtures.createShift(id: "shift-1", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        // Only one of two users exists
        let user1 = TestFixtures.createParent(id: "user-1")
        mockUserRepository.usersById["user-1"] = user1
        // user-2 does not exist
        
        let assignment1 = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        let assignment2 = TestFixtures.createAssignment(id: "a2", shiftId: "shift-1", userId: "user-2", status: .confirmed)
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([assignment1, assignment2])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.remindersSent == 1)
        #expect(response.failures == 1)
        #expect(response.reminders[0].success == false)
        #expect(response.reminders[0].errorMessage?.contains("1") == true)
    }
    
    @Test("Send reminders continues processing after failures")
    func sendRemindersContinuesAfterFailures() async throws {
        // Given
        let shift1 = TestFixtures.createShift(id: "shift-1", status: .published)
        let shift2 = TestFixtures.createShift(id: "shift-2", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift1, shift2])
        
        let user = TestFixtures.createParent(id: "user-1")
        mockUserRepository.usersById["user-1"] = user
        // user-2 does not exist - will fail
        
        // Add assignments for each shift
        let assignment1 = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-2", status: .confirmed) // Will fail
        let assignment2 = TestFixtures.createAssignment(id: "a2", shiftId: "shift-2", userId: "user-1", status: .confirmed) // Will succeed
        mockAssignmentRepository.assignmentsById["a1"] = assignment1
        mockAssignmentRepository.assignmentsById["a2"] = assignment2
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.shiftsProcessed == 2)
        #expect(response.remindersSent == 1)
        #expect(response.failures == 1)
        #expect(response.reminders.count == 2) // Both shifts processed
    }
    
    // MARK: - Response Content Tests
    
    @Test("Send reminders includes shift details in response")
    func sendRemindersIncludesShiftDetails() async throws {
        // Given
        let shiftDate = DateTestHelpers.date(2024, 12, 15)
        let shift = TestFixtures.createShift(
            id: "shift-1",
            date: shiftDate,
            label: "Tree Lot Morning",
            status: .published
        )
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        
        let user = TestFixtures.createParent(id: "user-1")
        mockUserRepository.usersById["user-1"] = user
        
        let assignment = TestFixtures.createAssignment(id: "a1", shiftId: "shift-1", userId: "user-1", status: .confirmed)
        mockAssignmentRepository.getAssignmentsForShiftResult = .success([assignment])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.reminders.count == 1)
        let entry = response.reminders[0]
        #expect(entry.shiftId == "shift-1")
        #expect(entry.shiftLabel == "Tree Lot Morning")
    }
    
    @Test("Send reminders includes processing time")
    func sendRemindersIncludesProcessingTime() async throws {
        // Given
        mockShiftRepository.getShiftsForDateRangeResult = .success([])
        
        // When
        let response = try await useCase.execute()
        
        // Then
        #expect(response.processingTimeSeconds >= 0)
        #expect(response.processedAt <= Date())
    }
    
    // MARK: - Date Range Tests
    
    @Test("Send reminders queries correct date range")
    func sendRemindersQueriesCorrectDateRange() async throws {
        // Given
        mockShiftRepository.getShiftsForDateRangeResult = .success([])
        
        // When
        _ = try await useCase.execute()
        
        // Then
        #expect(mockShiftRepository.getShiftsForDateRangeCallCount == 1)
        
        let (start, end) = mockShiftRepository.getShiftsForDateRangeCalledWith[0]
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .hour, value: 24, to: now)!
        
        // Window should be approximately 24 hours from now, ±30 minutes
        let expectedWindowStart = calendar.date(byAdding: .minute, value: -30, to: tomorrow)!
        let expectedWindowEnd = calendar.date(byAdding: .minute, value: 30, to: tomorrow)!
        
        // Allow some tolerance for test execution time
        let tolerance: TimeInterval = 5 // 5 seconds
        #expect(abs(start.timeIntervalSince(expectedWindowStart)) < tolerance)
        #expect(abs(end.timeIntervalSince(expectedWindowEnd)) < tolerance)
    }
    
    // MARK: - Error Tests
    
    @Test("Send reminders propagates shift repository error")
    func sendRemindersPropagatesShiftError() async throws {
        // Given
        mockShiftRepository.getShiftsForDateRangeResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
    }
    
    @Test("Send reminders propagates assignment repository error")
    func sendRemindersPropagatesAssignmentError() async throws {
        // Given
        let shift = TestFixtures.createShift(id: "shift-1", status: .published)
        mockShiftRepository.getShiftsForDateRangeResult = .success([shift])
        mockAssignmentRepository.getAssignmentsForShiftResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute()
        }
    }
}
