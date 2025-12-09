import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("UpdateAttendanceRecordUseCase Tests")
struct UpdateAttendanceRecordUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockUserRepository = MockUserRepository()
    
    private var useCase: UpdateAttendanceRecordUseCase {
        UpdateAttendanceRecordUseCase(
            attendanceRepository: mockAttendanceRepository,
            userRepository: mockUserRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Update attendance record succeeds for committee member")
    func updateAttendanceRecordSucceedsForCommittee() async throws {
        // Given
        let recordId = "attendance-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId, firstName: "Admin", lastName: "User")
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: recordId,
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: committeeUserId,
            checkInTime: nil,
            checkOutTime: Date(),
            status: .checkedOut,
            hoursWorked: 3.5,
            correctionNotes: "Forgot to check out",
            overrideReason: "Manual checkout"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        #expect(mockAttendanceRepository.updateAttendanceRecordCallCount == 1)
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.id.value == recordId)
        #expect(updatedRecord.status == .checkedOut)
        #expect(updatedRecord.hoursWorked == 3.5)
        #expect(updatedRecord.checkInMethod == .adminOverride)
        #expect(updatedRecord.notes?.contains("Admin override") == true)
        #expect(updatedRecord.notes?.contains("Admin User") == true)
        #expect(updatedRecord.notes?.contains("Manual checkout") == true)
    }
    
    @Test("Update attendance record updates check-in time")
    func updateAttendanceRecordUpdatesCheckInTime() async throws {
        // Given
        let recordId = "attendance-1"
        let committeeUserId = "committee-1"
        let newCheckInTime = DateTestHelpers.dateTime(2024, 12, 1, 9, 0)
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: recordId,
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: committeeUserId,
            checkInTime: newCheckInTime,
            checkOutTime: nil,
            status: nil,
            hoursWorked: nil,
            correctionNotes: nil,
            overrideReason: "Corrected check-in time"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.checkInTime == newCheckInTime)
    }
    
    @Test("Update attendance record calculates hours when both times provided")
    func updateAttendanceRecordCalculatesHours() async throws {
        // Given
        let recordId = "attendance-1"
        let committeeUserId = "committee-1"
        let checkInTime = DateTestHelpers.dateTime(2024, 12, 1, 9, 0)
        let checkOutTime = DateTestHelpers.dateTime(2024, 12, 1, 13, 30) // 4.5 hours later
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let existingRecord = TestFixtures.createAttendanceRecord(
            id: recordId,
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: "volunteer-1",
            status: .pending
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: committeeUserId,
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            status: .checkedOut,
            hoursWorked: nil, // Let it calculate
            correctionNotes: nil,
            overrideReason: "Adding times"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.hoursWorked == 4.5)
    }
    
    @Test("Update attendance record uses explicit hours over calculated")
    func updateAttendanceRecordUsesExplicitHours() async throws {
        // Given
        let recordId = "attendance-1"
        let committeeUserId = "committee-1"
        let checkInTime = DateTestHelpers.dateTime(2024, 12, 1, 9, 0)
        let checkOutTime = DateTestHelpers.dateTime(2024, 12, 1, 13, 0) // Would calculate to 4.0
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let existingRecord = TestFixtures.createAttendanceRecord(
            id: recordId,
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: "volunteer-1",
            status: .pending
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: committeeUserId,
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            status: .checkedOut,
            hoursWorked: 3.5, // Explicit override
            correctionNotes: "Took a break",
            overrideReason: "Break deduction"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.hoursWorked == 3.5)
    }
    
    @Test("Update attendance record appends notes to existing")
    func updateAttendanceRecordAppendsNotes() async throws {
        // Given
        let recordId = "attendance-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId, firstName: "Admin", lastName: "User")
        let existingRecord = AttendanceRecord(
            id: AttendanceRecordId(unchecked: recordId),
            assignmentId: AssignmentId(unchecked: "assignment-1"),
            shiftId: ShiftId(unchecked: "shift-1"),
            userId: UserId(unchecked: "volunteer-1"),
            checkInTime: Date(),
            checkOutTime: nil,
            checkInMethod: .qrCode,
            checkInLocation: nil,
            hoursWorked: nil,
            status: .checkedIn,
            notes: "Original notes"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: committeeUserId,
            checkInTime: nil,
            checkOutTime: nil,
            status: .checkedOut,
            hoursWorked: 4.0,
            correctionNotes: "Left early",
            overrideReason: "Early departure"
        )
        
        // When
        try await useCase.execute(request: request)
        
        // Then
        let updatedRecord = mockAttendanceRepository.updateAttendanceRecordCalledWith[0]
        #expect(updatedRecord.notes?.contains("Original notes") == true)
        #expect(updatedRecord.notes?.contains("Admin override by Admin User") == true)
        #expect(updatedRecord.notes?.contains("Early departure") == true)
        #expect(updatedRecord.notes?.contains("Left early") == true)
    }
    
    // MARK: - Permission Tests
    
    @Test("Update attendance record fails for non-committee user")
    func updateAttendanceRecordFailsForNonCommittee() async throws {
        // Given
        let recordId = "attendance-1"
        let parentUserId = "parent-1"
        
        let parentUser = TestFixtures.createParent(id: parentUserId)
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: recordId,
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[parentUserId] = parentUser
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: parentUserId,
            checkInTime: nil,
            checkOutTime: nil,
            status: .checkedOut,
            hoursWorked: 4.0,
            correctionNotes: nil,
            overrideReason: "Trying to hack"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceRepository.updateAttendanceRecordCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Update attendance record fails when record not found")
    func updateAttendanceRecordFailsWhenNotFound() async throws {
        // Given
        let committeeUserId = "committee-1"
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        mockUserRepository.usersById[committeeUserId] = committeeUser
        // No record in repository
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: "non-existent",
            requestingUserId: committeeUserId,
            checkInTime: nil,
            checkOutTime: nil,
            status: nil,
            hoursWorked: nil,
            correctionNotes: nil,
            overrideReason: "Test"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
    
    @Test("Update attendance record propagates repository error")
    func updateAttendanceRecordPropagatesError() async throws {
        // Given
        let recordId = "attendance-1"
        let committeeUserId = "committee-1"
        
        let committeeUser = TestFixtures.createCommittee(id: committeeUserId)
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: recordId,
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: "volunteer-1"
        )
        
        mockUserRepository.usersById[committeeUserId] = committeeUser
        mockAttendanceRepository.addRecord(existingRecord)
        mockAttendanceRepository.updateAttendanceRecordError = DomainError.networkError
        
        let request = UpdateAttendanceRecordRequest(
            attendanceRecordId: recordId,
            requestingUserId: committeeUserId,
            checkInTime: nil,
            checkOutTime: nil,
            status: .checkedOut,
            hoursWorked: 4.0,
            correctionNotes: nil,
            overrideReason: "Test"
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
    }
}
