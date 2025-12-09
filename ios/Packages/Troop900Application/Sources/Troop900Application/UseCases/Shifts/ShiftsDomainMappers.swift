import Foundation
import Troop900Domain

// MARK: - ShiftStatusType Mapping

extension ShiftStatusType {
    init(from domain: ShiftStatus) {
        switch domain {
        case .draft:
            self = .draft
        case .published:
            self = .published
        case .cancelled:
            self = .cancelled
        case .completed:
            self = .completed
        }
    }
    
    func toDomain() -> ShiftStatus {
        switch self {
        case .draft:
            return .draft
        case .published:
            return .published
        case .cancelled:
            return .cancelled
        case .completed:
            return .completed
        }
    }
}

// MARK: - StaffingStatusType Mapping

extension StaffingStatusType {
    init(from domain: StaffingStatus) {
        switch domain {
        case .empty:
            self = .empty
        case .partial:
            self = .partial
        case .full:
            self = .full
        }
    }
}

// MARK: - AssignmentTypeValue Mapping

extension AssignmentTypeValue {
    init(from domain: AssignmentType) {
        switch domain {
        case .scout:
            self = .scout
        case .parent:
            self = .parent
        }
    }
    
    func toDomain() -> AssignmentType {
        switch self {
        case .scout:
            return .scout
        case .parent:
            return .parent
        }
    }
}

// MARK: - AssignmentStatusType Mapping

extension AssignmentStatusType {
    init(from domain: AssignmentStatus) {
        switch domain {
        case .pending:
            self = .pending
        case .confirmed:
            self = .confirmed
        case .cancelled:
            self = .cancelled
        case .completed:
            self = .completed
        }
    }
    
    func toDomain() -> AssignmentStatus {
        switch self {
        case .pending:
            return .pending
        case .confirmed:
            return .confirmed
        case .cancelled:
            return .cancelled
        case .completed:
            return .completed
        }
    }
}

// MARK: - ShiftSummary Mapping

extension ShiftSummary {
    init(from shift: Shift) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let startTimeStr = formatter.string(from: shift.startTime)
        let endTimeStr = formatter.string(from: shift.endTime)
        
        self.init(
            id: shift.id.value,
            date: shift.date,
            startTime: shift.startTime,
            endTime: shift.endTime,
            requiredScouts: shift.requiredScouts,
            requiredParents: shift.requiredParents,
            currentScouts: shift.currentScouts,
            currentParents: shift.currentParents,
            location: shift.location,
            label: shift.label,
            status: ShiftStatusType(from: shift.status),
            staffingStatus: StaffingStatusType(from: shift.staffingStatus),
            timeRange: "\(startTimeStr) - \(endTimeStr)"
        )
    }
}

// MARK: - ShiftDetail Mapping

extension ShiftDetail {
    init(from shift: Shift) {
        self.init(
            id: shift.id.value,
            date: shift.date,
            startTime: shift.startTime,
            endTime: shift.endTime,
            requiredScouts: shift.requiredScouts,
            requiredParents: shift.requiredParents,
            currentScouts: shift.currentScouts,
            currentParents: shift.currentParents,
            location: shift.location,
            label: shift.label,
            notes: shift.notes,
            status: ShiftStatusType(from: shift.status),
            staffingStatus: StaffingStatusType(from: shift.staffingStatus),
            seasonId: shift.seasonId,
            needsScouts: shift.needsScouts,
            needsParents: shift.needsParents,
            durationMinutes: Int(shift.duration / 60)
        )
    }
}

// MARK: - AssignmentInfo Mapping

extension AssignmentInfo {
    init(from assignment: Assignment, userName: String) {
        self.init(
            id: assignment.id.value,
            userId: assignment.userId.value,
            userName: userName,
            assignmentType: AssignmentTypeValue(from: assignment.assignmentType),
            status: AssignmentStatusType(from: assignment.status),
            notes: assignment.notes,
            assignedAt: assignment.assignedAt
        )
    }
}
