import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("MarkNoShowUseCase Tests")
struct MarkNoShowUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: MarkNoShowUseCase {
        MarkNoShowUseCase(
            assignmentRepository: mockAssignmentRepository,
            attendanceRepository: mockAttendanceRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests - New Record
    
    @Test("Mark no-show creates new record when none exists")
    func markNoShowCreatesNewRecord() async throws {
        // Given
        let assignmentId = "assignment-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId, firstName: "Admin", lastName: "User")
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        // No existing attendance record
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: committeeUserId,
            notes: "Did not show up"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockAttendanceRepository.createAttendanceRecordCallCount == 1)
        let createdRecord = mockAttendanceRepository.createAttendanceRecordCalledWith[0]
        #expect(createdRecord.assignmentId == assignmentId)
        #expect(createdRecord.shiftId == "shift-1")
        #expect(createdRecord.userId == "volunteer-1")
        #expect(createdRecord.status == .noShow)
        #expect(createdRecord.checkInMethod == .adminOverride)
        #expect(createdRecord.checkInTime == nil)
        #expect(createdRecord.checkOutTime == nil)
        #expect(createdRecord.hoursWorked == nil)
        #expect(createdRecord.notes?.contains("Marked as no-show by Admin User") == true)
        #expect(createdRecord.notes?.contains("Did not show up") == true)
    }
    
    @Test("Mark no-show creates record without notes")
    func markNoShowCreatesRecordWithoutNotes() async throws {
        // Given
        let assignmentId = "assignment-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId, firstName: "Admin", lastName: "User")
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: committeeUserId,
            notes: nil
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockAttendanceRepository.createAttendanceRecordCallCount == 1)
        let createdRecord = mockAttendanceRepository.createAttendanceRecordCalledWith[0]
        #expect(createdRecord.status == .noShow)
        #expect(createdRecord.notes?.contains("Marked as no-show by Admin User") == true)
    }
    
    // MARK: - Success Tests - Update Existing Record
    
    @Test("Mark no-show updates existing checked-in record")
    func markNoShowUpdatesExistingCheckedInRecord() async throws {
        // Given
        let assignmentId = "assignment-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId, firstName: "Admin", lastName: "User")
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: committeeUserId,
            notes: "Actually did not show"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockAttendanceRepository.updateAttendanceRecordCallCount == 1)
        #expect(mockAttendanceRepository.createAttendanceRecordCallCount == 0) // Should update, not create
        
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.id == "attendance-1")
        #expect(updatedRecord.status == .noShow)
        #expect(updatedRecord.hoursWorked == nil)
        #expect(updatedRecord.notes?.contains("Marked as no-show by Admin User") == true)
        #expect(updatedRecord.notes?.contains("Actually did not show") == true)
    }
    
    @Test("Mark no-show preserves original notes when updating")
    func markNoShowPreservesOriginalNotes() async throws {
        // Given
        let assignmentId = "assignment-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId, firstName: "Admin", lastName: "User")
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        let existingRecord = AttendanceRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1",
            checkInTime: Date(),
            checkOutTime: nil,
            checkInMethod: .qrCode,
            checkInLocation: nil,
            hoursWorked: nil,
            status: .checkedIn,
            notes: "Original check-in notes"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: committeeUserId,
            notes: "Corrected status"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.notes?.contains("Original check-in notes") == true)
        #expect(updatedRecord.notes?.contains("Marked as no-show by Admin User") == true)
        #expect(updatedRecord.notes?.contains("Corrected status") == true)
    }
    
    // MARK: - Permission Tests
    
    @Test("Mark no-show fails for non-committee user")
    func markNoShowFailsForNonCommittee() async throws {
        // Given
        let assignmentId = "assignment-1"
        let parentUserId = "parent-1"
        
        let parentUser = TestFixtures.createParent(id: parentUserId)
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[parentUserId] = parentUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: parentUserId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceRepository.createAttendanceRecordCallCount == 0)
        #expect(mockAttendanceRepository.updateAttendanceRecordCallCount == 0)
    }
    
    @Test("Mark no-show fails for scout user")
    func markNoShowFailsForScout() async throws {
        // Given
        let assignmentId = "assignment-1"
        let scoutUserId = "scout-1"
        
        let scoutUser = TestFixtures.createScout(id: scoutUserId)
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[scoutUserId] = scoutUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: scoutUserId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    // MARK: - Error Tests
    
    @Test("Mark no-show fails when assignment not found")
    func markNoShowFailsWhenAssignmentNotFound() async throws {
        // Given
        let committeeUserId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        mockUserRepository.usersById[committeeUserId] = committeeUser
        // No assignment in repository
        
        let request = MarkNoShowRequest(
            assignmentId: "non-existent",
            requestingUserId: committeeUserId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Mark no-show fails when requesting user not found")
    func markNoShowFailsWhenUserNotFound() async throws {
        // Given
        let assignmentId = "assignment-1"
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        // Requesting user not in repository
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: "non-existent",
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Mark no-show propagates create error")
    func markNoShowPropagatesCreateError() async throws {
        // Given
        let assignmentId = "assignment-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockAttendanceRepository.createAttendanceRecordResult = .failure(DomainError.networkError)
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: committeeUserId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Mark no-show propagates update error")
    func markNoShowPropagatesUpdateError() async throws {
        // Given
        let assignmentId = "assignment-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockAttendanceRepository.addRecord(existingRecord)
        mockAttendanceRepository.updateAttendanceRecordError = DomainError.networkError
        
        let request = MarkNoShowRequest(
            assignmentId: assignmentId,
            requestingUserId: committeeUserId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
