import Foundation

/// Represents a user's assignment to a specific shift.
public struct Assignment: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let shiftId: String
    public let userId: String
    public let assignmentType: AssignmentType
    public let status: AssignmentStatus
    public let notes: String?
    public let assignedAt: Date
    public let assignedBy: String?
    
    public init(
        id: String,
        shiftId: String,
        userId: String,
        assignmentType: AssignmentType,
        status: AssignmentStatus,
        notes: String?,
        assignedAt: Date,
        assignedBy: String?
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
