import Foundation

/// Information about an assignment for display purposes.
public struct AssignmentInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let userId: String
    public let userName: String
    public let assignmentType: AssignmentTypeValue
    public let status: AssignmentStatusType
    public let notes: String?
    public let assignedAt: Date
    
    public init(
        id: String,
        userId: String,
        userName: String,
        assignmentType: AssignmentTypeValue,
        status: AssignmentStatusType,
        notes: String?,
        assignedAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.assignmentType = assignmentType
        self.status = status
        self.notes = notes
        self.assignedAt = assignedAt
    }
}
