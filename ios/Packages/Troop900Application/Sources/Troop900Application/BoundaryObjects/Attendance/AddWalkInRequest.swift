import Foundation

/// Request to add a walk-in volunteer to an in-progress shift.
/// Walk-ins are volunteers who show up without a pre-existing assignment.
public struct AddWalkInRequest: Sendable, Equatable {
    /// The ID of the shift to add the walk-in to
    public let shiftId: String
    
    /// The ID of the volunteer (walk-in)
    public let userId: String
    
    /// The ID of the user making the request (committee or checked-in parent)
    public let requestingUserId: String
    
    /// Optional notes about the walk-in
    public let notes: String?
    
    /// Type of assignment (scout or parent)
    public let assignmentType: ParticipantType
    
    public init(
        shiftId: String,
        userId: String,
        requestingUserId: String,
        notes: String?,
        assignmentType: ParticipantType
    ) {
        self.shiftId = shiftId
        self.userId = userId
        self.requestingUserId = requestingUserId
        self.notes = notes
        self.assignmentType = assignmentType
    }
}
