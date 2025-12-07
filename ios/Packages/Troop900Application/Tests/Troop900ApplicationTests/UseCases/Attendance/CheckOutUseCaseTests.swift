import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("CheckOutUseCase Tests")
struct CheckOutUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceService = MockAttendanceService()
    private let mockAttendanceRepository = MockAttendanceRepository()
    
    private var useCase: CheckOutUseCase {
        CheckOutUseCase(
            attendanceService: mockAttendanceService,
            attendanceRepository: mockAttendanceRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Check out succeeds when checked in")
    func checkOutSucceedsWhenCheckedIn() async throws {
        // Given
        let assignmentId = "assignment-1"
        let checkedInRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "user-1"
        )
        
        mockAttendanceRepository.addRecord(checkedInRecord)
        
        let request = CheckOutRequest(
            assignmentId: assignmentId,
            notes: "Great shift!"
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.checkOutTime != nil)
        #expect(response.hoursWorked > 0)
        #expect(response.message.contains("Successfully checked out"))
        #expect(mockAttendanceService.checkOutCallCount == 1)
        #expect(mockAttendanceService.checkOutCalledWith[0].assignmentId == assignmentId)
        #expect(mockAttendanceService.checkOutCalledWith[0].notes == "Great shift!")
    }
    
    @Test("Check out succeeds without notes")
    func checkOutSucceedsWithoutNotes() async throws {
        // Given
        let assignmentId = "assignment-1"
        let checkedInRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "user-1"
        )
        
        mockAttendanceRepository.addRecord(checkedInRecord)
        
        let request = CheckOutRequest(
            assignmentId: assignmentId,
            notes: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(mockAttendanceService.checkOutCalledWith[0].notes == nil)
    }
    
    @Test("Check out response includes formatted hours message")
    func checkOutResponseIncludesFormattedHours() async throws {
        // Given
        let assignmentId = "assignment-1"
        let checkedInRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "user-1"
        )
        
        mockAttendanceRepository.addRecord(checkedInRecord)
        mockAttendanceService.checkOutResult = .success(CheckOutServiceResponse(
            success: true,
            checkOutTime: Date(),
            hoursWorked: 3.5
        ))
        
        let request = CheckOutRequest(
            assignmentId: assignmentId,
            notes: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.hoursWorked == 3.5)
        #expect(response.message.contains("3.5"))
    }
    
    // MARK: - Validation Tests
    
    @Test("Check out fails when not checked in")
    func checkOutFailsWhenNotCheckedIn() async throws {
        // Given - no attendance record
        let request = CheckOutRequest(
            assignmentId: "assignment-1",
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkOutCallCount == 0)
    }
    
    @Test("Check out fails when already checked out")
    func checkOutFailsWhenAlreadyCheckedOut() async throws {
        // Given
        let assignmentId = "assignment-1"
        let completedRecord = TestFixtures.createCompletedRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "user-1",
            hoursWorked: 4.0
        )
        
        mockAttendanceRepository.addRecord(completedRecord)
        
        let request = CheckOutRequest(
            assignmentId: assignmentId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkOutCallCount == 0)
    }
    
    // MARK: - Service Error Tests
    
    @Test("Check out propagates service error")
    func checkOutPropagatesServiceError() async throws {
        // Given
        let assignmentId = "assignment-1"
        let checkedInRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: "shift-1",
            userId: "user-1"
        )
        
        mockAttendanceRepository.addRecord(checkedInRecord)
        mockAttendanceService.checkOutResult = .failure(DomainError.networkError)
        
        let request = CheckOutRequest(
            assignmentId: assignmentId,
            notes: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkOutCallCount == 1)
    }
}
