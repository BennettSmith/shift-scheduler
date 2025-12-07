import Foundation
import Troop900Domain

/// Mock implementation of ShiftSignupService for testing
public final class MockShiftSignupService: ShiftSignupService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var signUpResult: Result<ShiftSignupServiceResponse, Error>?
    public var cancelAssignmentError: Error?
    
    // MARK: - Call Tracking
    
    public var signUpCallCount = 0
    public var signUpCalledWith: [ShiftSignupServiceRequest] = []
    
    public var cancelAssignmentCallCount = 0
    public var cancelAssignmentCalledWith: [(assignmentId: String, reason: String?)] = []
    
    // MARK: - ShiftSignupService Implementation
    
    public func signUp(request: ShiftSignupServiceRequest) async throws -> ShiftSignupServiceResponse {
        signUpCallCount += 1
        signUpCalledWith.append(request)
        
        if let result = signUpResult {
            return try result.get()
        }
        
        // Default success response
        return ShiftSignupServiceResponse(
            success: true,
            assignmentId: "assignment-\(UUID().uuidString.prefix(8))",
            message: "Successfully signed up for shift"
        )
    }
    
    public func cancelAssignment(assignmentId: String, reason: String?) async throws {
        cancelAssignmentCallCount += 1
        cancelAssignmentCalledWith.append((assignmentId, reason))
        
        if let error = cancelAssignmentError {
            throw error
        }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        signUpResult = nil
        cancelAssignmentError = nil
        signUpCallCount = 0
        signUpCalledWith.removeAll()
        cancelAssignmentCallCount = 0
        cancelAssignmentCalledWith.removeAll()
    }
}
