import Foundation
import Troop900Domain

/// Simulated implementation of AttendanceService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedAttendanceService: AttendanceService, @unchecked Sendable {
    private let assignmentRepository: AssignmentRepository
    private let attendanceRepository: AttendanceRepository
    private let shiftRepository: ShiftRepository
    private let lock = AsyncLock()
    
    public init(
        assignmentRepository: AssignmentRepository,
        attendanceRepository: AttendanceRepository,
        shiftRepository: ShiftRepository
    ) {
        self.assignmentRepository = assignmentRepository
        self.attendanceRepository = attendanceRepository
        self.shiftRepository = shiftRepository
    }
    
    public func checkIn(request: CheckInServiceRequest) async throws -> CheckInServiceResponse {
        // Verify assignment exists and is active
        let assignment = try await assignmentRepository.getAssignment(id: request.assignmentId)
        guard assignment.isActive else {
            throw DomainError.assignmentNotActive
        }
        
        // Verify shift exists
        let shift = try await shiftRepository.getShift(id: request.shiftId)
        
        // Check if already checked in
        if let existingRecord = try await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: request.assignmentId) {
            if existingRecord.isCheckedIn {
                throw DomainError.alreadyCheckedIn
            }
        }
        
        // Create attendance record
        let checkInTime = Date()
        let recordId = try AttendanceRecordId(unchecked: UUID().uuidString)
        let record = AttendanceRecord(
            id: recordId,
            assignmentId: request.assignmentId,
            shiftId: request.shiftId,
            userId: assignment.userId,
            checkInTime: checkInTime,
            checkOutTime: nil,
            checkInMethod: request.qrCodeData != nil ? .qrCode : .manual,
            checkInLocation: request.location,
            hoursWorked: nil,
            status: .checkedIn,
            notes: nil
        )
        
        try await attendanceRepository.createAttendanceRecord(record)
        
        return CheckInServiceResponse(
            success: true,
            attendanceRecordId: recordId,
            checkInTime: checkInTime
        )
    }
    
    public func checkOut(assignmentId: AssignmentId, notes: String?) async throws -> CheckOutServiceResponse {
        // Get attendance record
        guard let record = try await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: assignmentId) else {
            throw DomainError.attendanceRecordNotFound
        }
        
        guard record.isCheckedIn else {
            throw DomainError.notCheckedIn
        }
        
        // Get shift to calculate hours
        let shift = try await shiftRepository.getShift(id: record.shiftId)
        let checkOutTime = Date()
        let hoursWorked = checkOutTime.timeIntervalSince(record.checkInTime!) / 3600.0
        
        // Update record
        let updatedRecord = AttendanceRecord(
            id: record.id,
            assignmentId: record.assignmentId,
            shiftId: record.shiftId,
            userId: record.userId,
            checkInTime: record.checkInTime,
            checkOutTime: checkOutTime,
            checkInMethod: record.checkInMethod,
            checkInLocation: record.checkInLocation,
            hoursWorked: hoursWorked,
            status: .checkedOut,
            notes: notes
        )
        
        try await attendanceRepository.updateAttendanceRecord(updatedRecord)
        
        return CheckOutServiceResponse(
            success: true,
            checkOutTime: checkOutTime,
            hoursWorked: hoursWorked
        )
    }
    
    public func adminManualCheckIn(request: AdminCheckInRequest) async throws -> CheckInServiceResponse {
        // Similar to checkIn but with override time
        let checkInTime = request.overrideTime ?? Date()
        
        // Verify assignment exists
        let assignment = try await assignmentRepository.getAssignment(id: request.assignmentId)
        
        // Create or update attendance record
        let recordId: AttendanceRecordId
        if let existingRecord = try await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: request.assignmentId) {
            recordId = existingRecord.id
            let updatedRecord = AttendanceRecord(
                id: existingRecord.id,
                assignmentId: existingRecord.assignmentId,
                shiftId: existingRecord.shiftId,
                userId: existingRecord.userId,
                checkInTime: checkInTime,
                checkOutTime: existingRecord.checkOutTime,
                checkInMethod: .adminOverride,
                checkInLocation: existingRecord.checkInLocation,
                hoursWorked: existingRecord.hoursWorked,
                status: .checkedIn,
                notes: request.notes ?? existingRecord.notes
            )
            try await attendanceRepository.updateAttendanceRecord(updatedRecord)
        } else {
            recordId = try AttendanceRecordId(unchecked: UUID().uuidString)
            let record = AttendanceRecord(
                id: recordId,
                assignmentId: request.assignmentId,
                shiftId: request.shiftId,
                userId: assignment.userId,
                checkInTime: checkInTime,
                checkOutTime: nil,
                checkInMethod: .adminOverride,
                checkInLocation: nil,
                hoursWorked: nil,
                status: .checkedIn,
                notes: request.notes
            )
            try await attendanceRepository.createAttendanceRecord(record)
        }
        
        return CheckInServiceResponse(
            success: true,
            attendanceRecordId: recordId,
            checkInTime: checkInTime
        )
    }
    
    public func adminManualCheckOut(request: AdminCheckOutRequest) async throws -> CheckOutServiceResponse {
        guard let record = try await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: request.assignmentId) else {
            throw DomainError.attendanceRecordNotFound
        }
        
        let checkOutTime = request.overrideTime ?? Date()
        let hoursWorked: Double
        if let checkInTime = record.checkInTime {
            hoursWorked = checkOutTime.timeIntervalSince(checkInTime) / 3600.0
        } else {
            hoursWorked = 0.0
        }
        
        let updatedRecord = AttendanceRecord(
            id: record.id,
            assignmentId: record.assignmentId,
            shiftId: record.shiftId,
            userId: record.userId,
            checkInTime: record.checkInTime ?? checkOutTime,
            checkOutTime: checkOutTime,
            checkInMethod: record.checkInMethod,
            checkInLocation: record.checkInLocation,
            hoursWorked: hoursWorked,
            status: .checkedOut,
            notes: request.notes ?? record.notes
        )
        
        try await attendanceRepository.updateAttendanceRecord(updatedRecord)
        
        return CheckOutServiceResponse(
            success: true,
            checkOutTime: checkOutTime,
            hoursWorked: hoursWorked
        )
    }
}
