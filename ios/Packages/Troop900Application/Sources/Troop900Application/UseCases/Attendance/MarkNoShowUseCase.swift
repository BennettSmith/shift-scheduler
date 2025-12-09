import Foundation
import Troop900Domain

/// Protocol for marking a volunteer as a no-show.
public protocol MarkNoShowUseCaseProtocol: Sendable {
    func execute(request: MarkNoShowRequest) async throws
}

/// Use case for marking a volunteer as a no-show for their shift.
/// Used by UC 31 for committee to mark volunteers who didn't show up.
public final class MarkNoShowUseCase: MarkNoShowUseCaseProtocol, Sendable {
    private let assignmentRepository: AssignmentRepository
    private let attendanceRepository: AttendanceRepository
    private let userRepository: UserRepository
    
    public init(
        assignmentRepository: AssignmentRepository,
        attendanceRepository: AttendanceRepository,
        userRepository: UserRepository
    ) {
        self.assignmentRepository = assignmentRepository
        self.attendanceRepository = attendanceRepository
        self.userRepository = userRepository
    }
    
    public func execute(request: MarkNoShowRequest) async throws {
        // Step 1: Validate and convert boundary IDs to domain ID types
        let assignmentId = try AssignmentId(request.assignmentId)
        let requestingUserId = try UserId(request.requestingUserId)
        
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        // Validate assignment exists
        let assignment = try await assignmentRepository.getAssignment(id: assignmentId)
        
        // Check if attendance record already exists
        if let existingRecord = try? await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: assignmentId) {
            // Update existing record to no-show
            let adminNotes = [
                existingRecord.notes,
                "Marked as no-show by \(requestingUser.fullName)",
                request.notes
            ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " | ")
            
            let updatedRecord = AttendanceRecord(
                id: existingRecord.id,
                assignmentId: existingRecord.assignmentId,
                shiftId: existingRecord.shiftId,
                userId: existingRecord.userId,
                checkInTime: existingRecord.checkInTime,
                checkOutTime: existingRecord.checkOutTime,
                checkInMethod: existingRecord.checkInMethod,
                checkInLocation: existingRecord.checkInLocation,
                hoursWorked: nil,
                status: .noShow,
                notes: adminNotes
            )
            
            try await attendanceRepository.updateAttendanceRecord(updatedRecord)
        } else {
            // Create new attendance record with no-show status
            let recordId = AttendanceRecordId(unchecked: UUID().uuidString)
            let adminNotes = [
                "Marked as no-show by \(requestingUser.fullName)",
                request.notes
            ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " | ")
            
            let record = AttendanceRecord(
                id: recordId,
                assignmentId: assignment.id,
                shiftId: assignment.shiftId,
                userId: assignment.userId,
                checkInTime: nil,
                checkOutTime: nil,
                checkInMethod: .adminOverride,
                checkInLocation: nil,
                hoursWorked: nil,
                status: .noShow,
                notes: adminNotes
            )
            
            _ = try await attendanceRepository.createAttendanceRecord(record)
        }
    }
}
