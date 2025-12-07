import Foundation
import Troop900Domain

/// Protocol for checking in to a shift.
public protocol CheckInUseCaseProtocol: Sendable {
    func execute(request: CheckInRequest) async throws -> CheckInResponse
}

/// Use case for checking in to a shift.
public final class CheckInUseCase: CheckInUseCaseProtocol, Sendable {
    private let attendanceService: AttendanceService
    private let assignmentRepository: AssignmentRepository
    private let attendanceRepository: AttendanceRepository
    
    public init(
        attendanceService: AttendanceService,
        assignmentRepository: AssignmentRepository,
        attendanceRepository: AttendanceRepository
    ) {
        self.attendanceService = attendanceService
        self.assignmentRepository = assignmentRepository
        self.attendanceRepository = attendanceRepository
    }
    
    public func execute(request: CheckInRequest) async throws -> CheckInResponse {
        // Validate assignment exists and is active
        let assignment = try await assignmentRepository.getAssignment(id: request.assignmentId)
        
        guard assignment.isActive else {
            throw DomainError.assignmentNotActive
        }
        
        // Check if already checked in
        if let existingRecord = try? await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: request.assignmentId),
           existingRecord.isCheckedIn {
            throw DomainError.alreadyCheckedIn
        }
        
        // Call service to check in (Cloud Function handles validation and creation)
        let serviceRequest = CheckInServiceRequest(
            assignmentId: request.assignmentId,
            shiftId: request.shiftId,
            qrCodeData: request.qrCodeData,
            location: request.location
        )
        
        let serviceResponse = try await attendanceService.checkIn(request: serviceRequest)
        
        return CheckInResponse(
            success: serviceResponse.success,
            attendanceRecordId: serviceResponse.attendanceRecordId,
            checkInTime: serviceResponse.checkInTime,
            message: "Successfully checked in!"
        )
    }
}
