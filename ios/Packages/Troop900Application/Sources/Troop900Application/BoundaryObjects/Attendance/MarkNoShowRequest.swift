import Foundation

/// Request to mark a volunteer as a no-show for a shift.
public struct MarkNoShowRequest: Sendable, Equatable {
    /// The ID of the assignment to mark as no-show
    public let assignmentId: String
    
    /// The ID of the user making the request (must be admin)
    public let requestingUserId: String
    
    /// Optional notes about the no-show
    public let notes: String?
    
    public init(
        assignmentId: String,
        requestingUserId: String,
        notes: String?
    ) {
        self.assignmentId = assignmentId
        self.requestingUserId = requestingUserId
        self.notes = notes
    }
}
