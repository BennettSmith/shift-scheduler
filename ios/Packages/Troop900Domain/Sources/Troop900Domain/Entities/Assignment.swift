import Foundation

/// Represents a user's assignment to a specific shift.
public struct Assignment: Identifiable, Equatable, Sendable, Codable {
    public let id: AssignmentId
    public let shiftId: ShiftId
    public let userId: UserId
    public let assignmentType: AssignmentType
    public let status: AssignmentStatus
    public let notes: String?
    public let assignedAt: Date
    public let assignedBy: UserId?
    
    public init(
        id: AssignmentId,
        shiftId: ShiftId,
        userId: UserId,
        assignmentType: AssignmentType,
        status: AssignmentStatus,
        notes: String?,
        assignedAt: Date,
        assignedBy: UserId?
    ) {
        self.id = id
        self.shiftId = shiftId
        self.userId = userId
        self.assignmentType = assignmentType
        self.status = status
        self.notes = notes
        self.assignedAt = assignedAt
        self.assignedBy = assignedBy
    }
    
    public var isActive: Bool {
        status.isActive
    }
}
