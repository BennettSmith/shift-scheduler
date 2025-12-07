import Foundation
import Troop900Domain

/// Protocol for adding a walk-in volunteer to a shift.
public protocol AddWalkInAssignmentUseCaseProtocol: Sendable {
    func execute(request: AddWalkInRequest) async throws -> AddWalkInResponse
}

/// Use case for adding a walk-in volunteer to an in-progress shift.
/// Handles UC 33, 34, 35 with permission checks for committee vs checked-in parent.
public final class AddWalkInAssignmentUseCase: AddWalkInAssignmentUseCaseProtocol, Sendable {
    private let shiftRepository: ShiftRepository
    private let assignmentRepository: AssignmentRepository
    private let attendanceRepository: AttendanceRepository
    private let userRepository: UserRepository
    private let attendanceService: AttendanceService
    
    public init(
        shiftRepository: ShiftRepository,
        assignmentRepository: AssignmentRepository,
        attendanceRepository: AttendanceRepository,
        userRepository: UserRepository,
        attendanceService: AttendanceService
    ) {
        self.shiftRepository = shiftRepository
        self.assignmentRepository = assignmentRepository
        self.attendanceRepository = attendanceRepository
        self.userRepository = userRepository
        self.attendanceService = attendanceService
    }
    
    public func execute(request: AddWalkInRequest) async throws -> AddWalkInResponse {
        // Validate shift exists
        let shift = try await shiftRepository.getShift(id: request.shiftId)
        
        // Validate shift is in progress or about to start
        let now = Date()
        guard shift.startTime <= now else {
            return AddWalkInResponse(
                success: false,
                assignmentId: nil,
                attendanceRecordId: nil,
                message: "Cannot add walk-ins to shifts that haven't started yet",
                autoCheckedIn: false
            )
        }
        
        // Validate requesting user and permissions
        let requestingUser = try await userRepository.getUser(id: request.requestingUserId)
        let isCommittee = requestingUser.role.isLeadership
        
        // If not committee, must be a checked-in parent on this shift
        var hasPermission = isCommittee
        if !isCommittee {
            // Check if requesting user is checked in for this shift
            let requestingUserAssignments = try await assignmentRepository.getAssignmentsForUser(userId: request.requestingUserId)
            let shiftAssignments = requestingUserAssignments.filter { $0.shiftId == request.shiftId && $0.isActive }
            
            if let assignment = shiftAssignments.first {
                if let attendanceRecord = try? await attendanceRepository.getAttendanceRecordByAssignment(assignmentId: assignment.id),
                   attendanceRecord.isCheckedIn {
                    hasPermission = true
                }
            }
        }
        
        guard hasPermission else {
            throw DomainError.unauthorized
        }
        
        // Validate walk-in user exists
        let walkInUser = try await userRepository.getUser(id: request.userId)
        
        // Check if user already has an assignment for this shift
        let existingAssignments = try await assignmentRepository.getAssignmentsForUser(userId: request.userId)
        let shiftAssignments = existingAssignments.filter { $0.shiftId == request.shiftId && $0.isActive }
        
        if !shiftAssignments.isEmpty {
            return AddWalkInResponse(
                success: false,
                assignmentId: nil,
                attendanceRecordId: nil,
                message: "\(walkInUser.firstName) already has an assignment for this shift",
                autoCheckedIn: false
            )
        }
        
        // Create assignment for walk-in
        let assignmentId = UUID().uuidString
        let assignment = Assignment(
            id: assignmentId,
            shiftId: request.shiftId,
            userId: request.userId,
            assignmentType: request.assignmentType,
            status: .confirmed,
            notes: request.notes,
            assignedAt: now,
            assignedBy: request.requestingUserId
        )
        
        _ = try await assignmentRepository.createAssignment(assignment)
        
        // Auto-check in the walk-in
        let attendanceRecordId = UUID().uuidString
        let attendanceRecord = AttendanceRecord(
            id: attendanceRecordId,
            assignmentId: assignmentId,
            shiftId: request.shiftId,
            userId: request.userId,
            checkInTime: now,
            checkOutTime: nil,
            checkInMethod: .manual,
            checkInLocation: nil,
            hoursWorked: nil,
            status: .checkedIn,
            notes: "Walk-in volunteer added by \(requestingUser.firstName) \(requestingUser.lastName)"
        )
        
        _ = try await attendanceRepository.createAttendanceRecord(attendanceRecord)
        
        return AddWalkInResponse(
            success: true,
            assignmentId: assignmentId,
            attendanceRecordId: attendanceRecordId,
            message: "Successfully added \(walkInUser.firstName) as a walk-in volunteer",
            autoCheckedIn: true
        )
    }
}
