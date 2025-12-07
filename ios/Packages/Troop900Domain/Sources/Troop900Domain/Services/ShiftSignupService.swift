import Foundation

/// Protocol for shift signup remote operations (Cloud Functions).
public protocol ShiftSignupService: Sendable {
    /// Sign up for a shift.
    /// - Parameter request: The signup request.
    /// - Returns: The signup result.
    func signUp(request: ShiftSignupServiceRequest) async throws -> ShiftSignupServiceResponse
    
    /// Cancel an assignment.
    /// - Parameters:
    ///   - assignmentId: The assignment's ID.
    ///   - reason: Optional reason for cancellation.
    func cancelAssignment(assignmentId: String, reason: String?) async throws
}

/// Request to sign up for a shift.
public struct ShiftSignupServiceRequest: Sendable, Codable {
    public let shiftId: String
    public let userId: String
    public let assignmentType: AssignmentType
    public let notes: String?
    
    public init(
        shiftId: String,
        userId: String,
        assignmentType: AssignmentType,
        notes: String?
    ) {
        self.shiftId = shiftId
        self.userId = userId
        self.assignmentType = assignmentType
        self.notes = notes
    }
}

/// Response from shift signup operation.
public struct ShiftSignupServiceResponse: Sendable, Codable {
    public let success: Bool
    public let assignmentId: String
    public let message: String
    
    public init(success: Bool, assignmentId: String, message: String) {
        self.success = success
        self.assignmentId = assignmentId
        self.message = message
    }
}
