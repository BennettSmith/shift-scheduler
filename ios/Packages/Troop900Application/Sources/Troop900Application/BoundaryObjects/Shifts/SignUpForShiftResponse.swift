import Foundation
import Troop900Domain

/// Response after signing up for a shift.
public struct SignUpForShiftResponse: Sendable, Equatable {
    public let success: Bool
    public let assignmentId: String
    public let message: String
    
    public init(success: Bool, assignmentId: String, message: String) {
        self.success = success
        self.assignmentId = assignmentId
        self.message = message
    }
}
