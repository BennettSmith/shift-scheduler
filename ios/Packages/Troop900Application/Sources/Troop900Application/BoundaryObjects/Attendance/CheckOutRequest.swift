import Foundation

/// Request to check out from a shift.
public struct CheckOutRequest: Sendable, Equatable {
    public let assignmentId: String
    public let notes: String?
    
    public init(assignmentId: String, notes: String?) {
        self.assignmentId = assignmentId
        self.notes = notes
    }
}
