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
        // Step 1: Validate and convert boundary IDs to domain ID types
        let assignmentId = try AssignmentId(request.assignmentId)
        let shiftId = try ShiftId(request.shiftId)
        
        // Step 2: Convert boundary types to domain types
        let location = request.location.map { GeoLocation(from: $0) }
        
        // Validate assignment exists and is active
        let assignment = try await assignmentRepository.getAssignment(id: assignmentId)
        
        guard assignment.isActive else {
            throw DomainError.assignmentNotActive
        }
        
        // Check if already checked in
        if let existingRecord = try? await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: assignmentId),
           existingRecord.isCheckedIn {
            throw DomainError.alreadyCheckedIn
        }
        
        // Call service to check in (Cloud Function handles validation and creation)
        let serviceRequest = CheckInServiceRequest(
            assignmentId: assignmentId,
            shiftId: shiftId,
            qrCodeData: request.qrCodeData,
            location: location
        )
        
        let serviceResponse = try await attendanceService.checkIn(request: serviceRequest)
        
        return CheckInResponse(
            success: serviceResponse.success,
            attendanceRecordId: serviceResponse.attendanceRecordId.value,
            checkInTime: serviceResponse.checkInTime,
            message: "Successfully checked in!"
        )
    }
}
