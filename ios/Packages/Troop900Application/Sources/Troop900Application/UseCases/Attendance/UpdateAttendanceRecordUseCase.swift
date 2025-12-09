import Foundation
import Troop900Domain

/// Protocol for updating an attendance record (admin override).
public protocol UpdateAttendanceRecordUseCaseProtocol: Sendable {
    func execute(request: UpdateAttendanceRecordRequest) async throws
}

/// Use case for updating an attendance record with administrative override.
/// Used by UC 31 for committee to fix incorrect attendance records.
public final class UpdateAttendanceRecordUseCase: UpdateAttendanceRecordUseCaseProtocol, Sendable {
    private let attendanceRepository: AttendanceRepository
    private let userRepository: UserRepository
    
    public init(
        attendanceRepository: AttendanceRepository,
        userRepository: UserRepository
    ) {
        self.attendanceRepository = attendanceRepository
        self.userRepository = userRepository
    }
    
    public func execute(request: UpdateAttendanceRecordRequest) async throws {
        // Step 1: Validate and convert boundary IDs to domain ID types
        let attendanceRecordId = try AttendanceRecordId(request.attendanceRecordId)
        let requestingUserId = try UserId(request.requestingUserId)
        
        // Step 2: Convert boundary enums to domain types (if provided)
        let newStatus = request.status.map { AttendanceStatus(from: $0) }
        
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        // Get existing attendance record
        let existingRecord = try await attendanceRepository.getAttendanceRecord(id: attendanceRecordId)
        
        // Calculate hours worked if both times are provided
        var calculatedHours: Double? = existingRecord.hoursWorked
        if let checkIn = request.checkInTime ?? existingRecord.checkInTime,
           let checkOut = request.checkOutTime ?? existingRecord.checkOutTime {
            calculatedHours = checkOut.timeIntervalSince(checkIn) / 3600.0 // Convert to hours
        }
        
        // Create updated record with admin override notes
        let adminNotes = [
            existingRecord.notes,
            "Admin override by \(requestingUser.fullName): \(request.overrideReason)",
            request.correctionNotes
        ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " | ")
        
        let updatedRecord = AttendanceRecord(
            id: existingRecord.id,
            assignmentId: existingRecord.assignmentId,
            shiftId: existingRecord.shiftId,
            userId: existingRecord.userId,
            checkInTime: request.checkInTime ?? existingRecord.checkInTime,
            checkOutTime: request.checkOutTime ?? existingRecord.checkOutTime,
            checkInMethod: .adminOverride,
            checkInLocation: existingRecord.checkInLocation,
            hoursWorked: request.hoursWorked ?? calculatedHours,
            status: newStatus ?? existingRecord.status,
            notes: adminNotes
        )
        
        try await attendanceRepository.updateAttendanceRecord(updatedRecord)
    }
}
