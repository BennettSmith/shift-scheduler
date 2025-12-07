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
        // Validate user is checked in
        guard let attendanceRecord = try? await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: request.assignmentId),
              attendanceRecord.isCheckedIn else {
            throw DomainError.notCheckedIn
        }
        
        // Call service to check out (Cloud Function handles calculation and update)
        let serviceResponse = try await attendanceService.checkOut(
            assignmentId: request.assignmentId,
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
