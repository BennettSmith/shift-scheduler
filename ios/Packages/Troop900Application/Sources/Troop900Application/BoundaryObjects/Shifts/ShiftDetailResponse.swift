import Foundation

/// Detailed information about a shift for the detail view.
public struct ShiftDetail: Sendable, Equatable, Identifiable {
    public let id: String
    public let date: Date
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let currentScouts: Int
    public let currentParents: Int
    public let location: String
    public let label: String?
    public let notes: String?
    public let status: ShiftStatusType
    public let staffingStatus: StaffingStatusType
    public let seasonId: String?
    public let needsScouts: Bool
    public let needsParents: Bool
    public let durationMinutes: Int
    
    public init(
        id: String,
        date: Date,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        currentScouts: Int,
        currentParents: Int,
        location: String,
        label: String?,
        notes: String?,
        status: ShiftStatusType,
        staffingStatus: StaffingStatusType,
        seasonId: String?,
        needsScouts: Bool,
        needsParents: Bool,
        durationMinutes: Int
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.currentScouts = currentScouts
        self.currentParents = currentParents
        self.location = location
        self.label = label
        self.notes = notes
        self.status = status
        self.staffingStatus = staffingStatus
        self.seasonId = seasonId
        self.needsScouts = needsScouts
        self.needsParents = needsParents
        self.durationMinutes = durationMinutes
    }
}

/// Response containing detailed information about a specific shift.
public struct ShiftDetailResponse: Sendable, Equatable {
    public let shift: ShiftDetail
    public let assignments: [AssignmentInfo]
    public let canSignUp: Bool
    public let canCancel: Bool
    public let userAssignment: AssignmentInfo?
    
    public init(
        shift: ShiftDetail,
        assignments: [AssignmentInfo],
        canSignUp: Bool,
        canCancel: Bool,
        userAssignment: AssignmentInfo?
    ) {
        self.shift = shift
        self.assignments = assignments
        self.canSignUp = canSignUp
        self.canCancel = canCancel
        self.userAssignment = userAssignment
    }
}
