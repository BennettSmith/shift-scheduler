import Foundation
import Troop900Domain

/// Protocol for getting detailed attendance information for a shift.
public protocol GetShiftAttendanceDetailsUseCaseProtocol: Sendable {
    func execute(shiftId: String, requestingUserId: String) async throws -> ShiftAttendanceDetailsResponse
}

/// Use case for getting detailed attendance information for committee review.
/// Used by UC 31 for committee to review shift attendance.
public final class GetShiftAttendanceDetailsUseCase: GetShiftAttendanceDetailsUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let assignmentRepository: AssignmentRepository
    private let attendanceRepository: AttendanceRepository
    private let userRepository: UserRepository
    
    public init(
        shiftRepository: ShiftRepository,
        assignmentRepository: AssignmentRepository,
        attendanceRepository: AttendanceRepository,
        userRepository: UserRepository
    ) {
        self.shiftRepository = shiftRepository
        self.assignmentRepository = assignmentRepository
        self.attendanceRepository = attendanceRepository
        self.userRepository = userRepository
    }
    
    public func execute(shiftId: String, requestingUserId: String) async throws -> ShiftAttendanceDetailsResponse {
        // Validate requesting user has permission (must be committee)
        let requestingUser = try await userRepository.getUser(id: requestingUserId)
        guard requestingUser.role.isLeadership else {
            throw DomainError.unauthorized
        }
        
        // Get shift
        let shift = try await shiftRepository.getShift(id: shiftId)
        
        // Get all assignments for this shift
        let assignments = try await assignmentRepository.getAssignmentsForShift(shiftId: shiftId)
        
        // Get all attendance records for this shift
        let attendanceRecords = try await attendanceRepository.getAttendanceRecordsForShift(shiftId: shiftId)
        
        // Create a map of attendance records by assignment ID
        let attendanceMap = Dictionary(uniqueKeysWithValues: attendanceRecords.map { ($0.assignmentId, $0) })
        
        // Build detailed attendance records
        var detailRecords: [AttendanceRecordDetail] = []
        var checkedInCount = 0
        var checkedOutCount = 0
        var noShowCount = 0
        var totalHours = 0.0
        
        for assignment in assignments {
            // Get user info
            let user = try await userRepository.getUser(id: assignment.userId)
            
            // Get attendance record if exists
            let attendanceRecord = attendanceMap[assignment.id]
            
            // Determine if this is a walk-in (assignment created by someone else)
            let isWalkIn = assignment.assignedBy != nil && assignment.assignedBy != assignment.userId
            
            let detail = AttendanceRecordDetail(
                id: attendanceRecord?.id ?? assignment.id,
                assignmentId: assignment.id,
                userId: user.id,
                userName: user.fullName,
                userRole: user.role,
                assignmentType: assignment.assignmentType,
                checkInTime: attendanceRecord?.checkInTime,
                checkOutTime: attendanceRecord?.checkOutTime,
                checkInMethod: attendanceRecord?.checkInMethod ?? .manual,
                checkInLocation: attendanceRecord?.checkInLocation,
                hoursWorked: attendanceRecord?.hoursWorked,
                status: attendanceRecord?.status ?? .pending,
                notes: attendanceRecord?.notes ?? assignment.notes,
                isWalkIn: isWalkIn
            )
            
            detailRecords.append(detail)
            
            // Update counts
            if let record = attendanceRecord {
                if record.status == .checkedIn || record.status == .checkedOut {
                    checkedInCount += 1
                }
                if record.status == .checkedOut {
                    checkedOutCount += 1
                    totalHours += record.hoursWorked ?? 0
                }
                if record.status == .noShow {
                    noShowCount += 1
                }
            }
        }
        
        return ShiftAttendanceDetailsResponse(
            shiftId: shift.id,
            shiftDate: shift.date,
            shiftLabel: shift.label,
            totalAssigned: assignments.count,
            checkedInCount: checkedInCount,
            checkedOutCount: checkedOutCount,
            noShowCount: noShowCount,
            attendanceRecords: detailRecords,
            totalHoursWorked: totalHours
        )
    }
}
