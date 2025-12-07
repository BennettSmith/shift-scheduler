import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetAttendanceHistoryUseCase Tests")
struct GetAttendanceHistoryUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceRepository = MockAttendanceRepository()
    private let mockShiftRepository = MockShiftRepository()
    
    private var useCase: GetAttendanceHistoryUseCase {
        GetAttendanceHistoryUseCase(
            attendanceRepository: mockAttendanceRepository,
            shiftRepository: mockShiftRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get attendance history returns empty when no records")
    func getAttendanceHistoryReturnsEmptyWhenNoRecords() async throws {
        // Given
        let userId = "user-1"
        // No records in repository
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.records.isEmpty)
        #expect(response.totalHours == 0)
        #expect(response.completedShifts == 0)
    }
    
    @Test("Get attendance history returns records with shift info")
    func getAttendanceHistoryReturnsRecordsWithShiftInfo() async throws {
        // Given
        let userId = "user-1"
        let shiftDate = DateTestHelpers.date(2024, 12, 1)
        
        let shift = TestFixtures.createShift(
            id: "shift-1",
            date: shiftDate,
            label: "Morning Shift"
        )
        let record = TestFixtures.createCompletedRecord(
            id: "attendance-1",
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: userId,
            hoursWorked: 4.0
        )
        
        mockShiftRepository.shiftsById["shift-1"] = shift
        mockAttendanceRepository.addRecord(record)
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.records.count == 1)
        #expect(response.records[0].shiftLabel == "Morning Shift")
        #expect(response.records[0].hoursWorked == 4.0)
        #expect(response.records[0].status == .checkedOut)
    }
    
    @Test("Get attendance history calculates total hours")
    func getAttendanceHistoryCalculatesTotalHours() async throws {
        // Given
        let userId = "user-1"
        
        let shift1 = TestFixtures.createShift(id: "shift-1", date: DateTestHelpers.date(2024, 12, 1))
        let shift2 = TestFixtures.createShift(id: "shift-2", date: DateTestHelpers.date(2024, 12, 2))
        let shift3 = TestFixtures.createShift(id: "shift-3", date: DateTestHelpers.date(2024, 12, 3))
        
        let record1 = TestFixtures.createCompletedRecord(
            id: "attendance-1",
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: userId,
            hoursWorked: 4.0
        )
        let record2 = TestFixtures.createCompletedRecord(
            id: "attendance-2",
            assignmentId: "assignment-2",
            shiftId: "shift-2",
            userId: userId,
            hoursWorked: 3.5
        )
        let record3 = TestFixtures.createCompletedRecord(
            id: "attendance-3",
            assignmentId: "assignment-3",
            shiftId: "shift-3",
            userId: userId,
            hoursWorked: 2.5
        )
        
        mockShiftRepository.shiftsById["shift-1"] = shift1
        mockShiftRepository.shiftsById["shift-2"] = shift2
        mockShiftRepository.shiftsById["shift-3"] = shift3
        mockAttendanceRepository.addRecord(record1)
        mockAttendanceRepository.addRecord(record2)
        mockAttendanceRepository.addRecord(record3)
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.totalHours == 10.0) // 4.0 + 3.5 + 2.5
        #expect(response.completedShifts == 3)
    }
    
    @Test("Get attendance history counts completed shifts")
    func getAttendanceHistoryCountsCompletedShifts() async throws {
        // Given
        let userId = "user-1"
        
        let shift1 = TestFixtures.createShift(id: "shift-1", date: DateTestHelpers.date(2024, 12, 1))
        let shift2 = TestFixtures.createShift(id: "shift-2", date: DateTestHelpers.date(2024, 12, 2))
        
        // Completed record
        let completedRecord = TestFixtures.createCompletedRecord(
            id: "attendance-1",
            assignmentId: "assignment-1",
            shiftId: "shift-1",
            userId: userId,
            hoursWorked: 4.0
        )
        // Checked in but not out (incomplete)
        let incompleteRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-2",
            assignmentId: "assignment-2",
            shiftId: "shift-2",
            userId: userId
        )
        
        mockShiftRepository.shiftsById["shift-1"] = shift1
        mockShiftRepository.shiftsById["shift-2"] = shift2
        mockAttendanceRepository.addRecord(completedRecord)
        mockAttendanceRepository.addRecord(incompleteRecord)
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.records.count == 2)
        #expect(response.completedShifts == 1) // Only the completed one
    }
    
    @Test("Get attendance history sorts by date descending")
    func getAttendanceHistorySortsByDateDescending() async throws {
        // Given
        let userId = "user-1"
        
        let olderDate = DateTestHelpers.date(2024, 12, 1)
        let newerDate = DateTestHelpers.date(2024, 12, 15)
        
        let olderShift = TestFixtures.createShift(id: "older-shift", date: olderDate, label: "Older")
        let newerShift = TestFixtures.createShift(id: "newer-shift", date: newerDate, label: "Newer")
        
        // Add older record first
        let olderRecord = TestFixtures.createCompletedRecord(
            id: "attendance-1",
            assignmentId: "assignment-1",
            shiftId: "older-shift",
            userId: userId,
            hoursWorked: 3.0
        )
        let newerRecord = TestFixtures.createCompletedRecord(
            id: "attendance-2",
            assignmentId: "assignment-2",
            shiftId: "newer-shift",
            userId: userId,
            hoursWorked: 4.0
        )
        
        mockShiftRepository.shiftsById["older-shift"] = olderShift
        mockShiftRepository.shiftsById["newer-shift"] = newerShift
        mockAttendanceRepository.addRecord(olderRecord)
        mockAttendanceRepository.addRecord(newerRecord)
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.records.count == 2)
        #expect(response.records[0].shiftLabel == "Newer") // Most recent first
        #expect(response.records[1].shiftLabel == "Older")
    }
    
    @Test("Get attendance history handles missing shift gracefully")
    func getAttendanceHistoryHandlesMissingShift() async throws {
        // Given
        let userId = "user-1"
        
        let existingShift = TestFixtures.createShift(id: "existing-shift", date: DateTestHelpers.date(2024, 12, 1))
        
        let recordWithShift = TestFixtures.createCompletedRecord(
            id: "attendance-1",
            assignmentId: "assignment-1",
            shiftId: "existing-shift",
            userId: userId,
            hoursWorked: 4.0
        )
        let recordWithMissingShift = TestFixtures.createCompletedRecord(
            id: "attendance-2",
            assignmentId: "assignment-2",
            shiftId: "missing-shift",
            userId: userId,
            hoursWorked: 3.0
        )
        
        mockShiftRepository.shiftsById["existing-shift"] = existingShift
        // "missing-shift" not in repository
        mockAttendanceRepository.addRecord(recordWithShift)
        mockAttendanceRepository.addRecord(recordWithMissingShift)
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then - only includes record with existing shift
        #expect(response.records.count == 1)
        #expect(response.totalHours == 4.0) // Only from existing shift
    }
    
    // MARK: - Error Tests
    
    @Test("Get attendance history propagates repository error")
    func getAttendanceHistoryPropagatesError() async throws {
        // Given
        mockAttendanceRepository.getAttendanceRecordsForUserResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(userId: "user-1")
        }
    }
}
