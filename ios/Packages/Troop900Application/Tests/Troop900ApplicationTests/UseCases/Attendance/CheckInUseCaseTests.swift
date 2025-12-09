import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("CheckInUseCase Tests")
struct CheckInUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockAttendanceService = MockAttendanceService()
    private let mockAssignmentRepository = MockAssignmentRepository()
    private let mockAttendanceRepository = MockAttendanceRepository()
    
    private var useCase: CheckInUseCase {
        CheckInUseCase(
            attendanceService: mockAttendanceService,
            assignmentRepository: mockAssignmentRepository,
            attendanceRepository: mockAttendanceRepository
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Check in succeeds for active assignment")
    func checkInSucceedsForActiveAssignment() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = CheckInRequest(
            assignmentId: assignmentId,
            shiftId: shiftId,
            qrCodeData: "QR123",
            location: nil
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(response.attendanceRecordId.isEmpty == false)
        #expect(response.checkInTime != nil)
        #expect(response.message == "Successfully checked in!")
        #expect(mockAttendanceService.checkInCallCount == 1)
        #expect(mockAttendanceService.checkInCalledWith[0].assignmentId.value == assignmentId)
        #expect(mockAttendanceService.checkInCalledWith[0].shiftId.value == shiftId)
        #expect(mockAttendanceService.checkInCalledWith[0].qrCodeData == "QR123")
    }
    
    @Test("Check in succeeds with location data")
    func checkInSucceedsWithLocation() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        let location = Coordinate(latitude: 37.7749, longitude: -122.4194)
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        
        let request = CheckInRequest(
            assignmentId: assignmentId,
            shiftId: shiftId,
            qrCodeData: nil,
            location: location
        )
        
        // When
        let response = try await useCase.execute(request: request)
        
        // Then
        #expect(response.success == true)
        #expect(mockAttendanceService.checkInCalledWith[0].location?.latitude == 37.7749)
        #expect(mockAttendanceService.checkInCalledWith[0].location?.longitude == -122.4194)
    }
    
    // MARK: - Validation Tests
    
    @Test("Check in fails when assignment not found")
    func checkInFailsWhenAssignmentNotFound() async throws {
        // Given
        let request = CheckInRequest(
            assignmentId: "non-existent",
            shiftId: "shift-1",
            qrCodeData: nil,
            location: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkInCallCount == 0)
    }
    
    @Test("Check in fails when assignment is not active")
    func checkInFailsWhenAssignmentNotActive() async throws {
        // Given
        let assignmentId = "assignment-1"
        let cancelledAssignment = TestFixtures.createAssignment(
            id: assignmentId,
            status: .cancelled
        )
        
        mockAssignmentRepository.assignmentsById[assignmentId] = cancelledAssignment
        
        let request = CheckInRequest(
            assignmentId: assignmentId,
            shiftId: "shift-1",
            qrCodeData: nil,
            location: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkInCallCount == 0)
    }
    
    @Test("Check in fails when already checked in")
    func checkInFailsWhenAlreadyCheckedIn() async throws {
        // Given
        let assignmentId = "assignment-1"
        let shiftId = "shift-1"
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            shiftId: shiftId,
            status: .confirmed
        )
        let existingRecord = TestFixtures.createCheckedInRecord(
            id: "attendance-1",
            assignmentId: assignmentId,
            shiftId: shiftId,
            userId: "user-1"
        )
        
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockAttendanceRepository.addRecord(existingRecord)
        
        let request = CheckInRequest(
            assignmentId: assignmentId,
            shiftId: shiftId,
            qrCodeData: nil,
            location: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkInCallCount == 0)
    }
    
    // MARK: - Service Error Tests
    
    @Test("Check in propagates service error")
    func checkInPropagatesServiceError() async throws {
        // Given
        let assignmentId = "assignment-1"
        let assignment = TestFixtures.createAssignment(
            id: assignmentId,
            status: .confirmed
        )
        
        mockAssignmentRepository.assignmentsById[assignmentId] = assignment
        mockAttendanceService.checkInResult = .failure(DomainError.networkError)
        
        let request = CheckInRequest(
            assignmentId: assignmentId,
            shiftId: "shift-1",
            qrCodeData: nil,
            location: nil
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockAttendanceService.checkInCallCount == 1)
    }
}
