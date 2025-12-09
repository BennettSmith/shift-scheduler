import Foundation
import Troop900Domain

/// Protocol for checking out from a shift.
public protocol CheckOutUseCaseProtocol: Sendable {
    func execute(request: CheckOutRequest) async throws -> CheckOutResponse
}

/// Use case for checking out from a shift.
public final class CheckOutUseCase: CheckOutUseCaseProtocol, Sendable {
    private let attendanceService: AttendanceService
    private let attendanceRepository: AttendanceRepository
    
    public init(
        attendanceService: AttendanceService,
        attendanceRepository: AttendanceRepository
    ) {
        self.attendanceService = attendanceService
        self.attendanceRepository = attendanceRepository
    }
    
    public func execute(request: CheckOutRequest) async throws -> CheckOutResponse {
        // Step 1: Validate and convert boundary IDs to domain ID types
        let assignmentId = try AssignmentId(request.assignmentId)
        
        // Validate user is checked in
        guard let attendanceRecord = try? await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: assignmentId),
              attendanceRecord.isCheckedIn else {
            throw DomainError.notCheckedIn
        }
        
        // Call service to check out (Cloud Function handles calculation and update)
        let serviceResponse = try await attendanceService.checkOut(
            assignmentId: assignmentId,
            notes: request.notes
        )
        
        return CheckOutResponse(
            success: serviceResponse.success,
            checkOutTime: serviceResponse.checkOutTime,
            hoursWorked: serviceResponse.hoursWorked,
            message: "Successfully checked out! You worked \(String(format: "%.1f", serviceResponse.hoursWorked)) hours."
        )
    }
}
