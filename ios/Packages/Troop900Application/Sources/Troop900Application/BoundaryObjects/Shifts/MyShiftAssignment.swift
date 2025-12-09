import Foundation

/// A user's shift assignment combining both assignment and shift details.
/// Used by GetMyShiftsUseCase to provide all info needed for check-in/out/cancel.
public struct MyShiftAssignment: Sendable, Equatable, Identifiable {
    // Assignment info - the `id` IS the assignmentId
    public let id: String
    public let assignmentType: AssignmentTypeValue
    public let assignmentStatus: AssignmentStatusType
    public let assignedAt: Date
    public let notes: String?
    
    // Shift info (flattened for convenience)
    public let shiftId: String
    public let shiftDate: Date
    public let startTime: Date
    public let endTime: Date
    public let location: String
    public let label: String?
    public let shiftStatus: ShiftStatusType
    public let timeRange: String
    
    // Derived convenience properties
    public let canCheckIn: Bool
    public let canCancel: Bool
    
    public init(
        id: String,
        assignmentType: AssignmentTypeValue,
        assignmentStatus: AssignmentStatusType,
        assignedAt: Date,
        notes: String?,
        shiftId: String,
        shiftDate: Date,
        startTime: Date,
        endTime: Date,
        location: String,
        label: String?,
        shiftStatus: ShiftStatusType,
        timeRange: String,
        canCheckIn: Bool,
        canCancel: Bool
    ) {
        self.id = id
        self.assignmentType = assignmentType
        self.assignmentStatus = assignmentStatus
        self.assignedAt = assignedAt
        self.notes = notes
        self.shiftId = shiftId
        self.shiftDate = shiftDate
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.label = label
        self.shiftStatus = shiftStatus
        self.timeRange = timeRange
        self.canCheckIn = canCheckIn
        self.canCancel = canCancel
    }
}
