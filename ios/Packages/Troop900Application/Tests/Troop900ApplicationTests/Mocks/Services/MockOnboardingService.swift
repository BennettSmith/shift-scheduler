import Foundation
import Troop900Domain

/// Mock implementation of OnboardingService for testing
public final class MockOnboardingService: OnboardingService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var processInviteCodeResult: Result<InviteCodeResult, Error>?
    public var claimProfileResult: Result<ClaimProfileResult, Error>?
    
    // MARK: - Call Tracking
    
    public var processInviteCodeCallCount = 0
    public var processInviteCodeCalledWith: [(code: String, userId: String)] = []
    
    public var claimProfileCallCount = 0
    public var claimProfileCalledWith: [(claimCode: String, userId: String)] = []
    
    // MARK: - OnboardingService Implementation
    
    public func processInviteCode(code: String, userId: String) async throws -> InviteCodeResult {
        processInviteCodeCallCount += 1
        processInviteCodeCalledWith.append((code, userId))
        
        if let result = processInviteCodeResult {
            return try result.get()
        }
        
        // Default success response
        return InviteCodeResult(
            success: true,
            householdId: "household-\(UUID().uuidString.prefix(8))",
            userRole: .parent,
            message: "Invite code processed successfully"
        )
    }
    
    public func claimProfile(claimCode: String, userId: String) async throws -> ClaimProfileResult {
        claimProfileCallCount += 1
        claimProfileCalledWith.append((claimCode, userId))
        
        if let result = claimProfileResult {
            return try result.get()
        }
        
        // Default success response
        return ClaimProfileResult(
            success: true,
            userId: userId,
            message: "Profile claimed successfully"
        )
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        processInviteCodeResult = nil
        claimProfileResult = nil
        processInviteCodeCallCount = 0
        processInviteCodeCalledWith.removeAll()
        claimProfileCallCount = 0
        claimProfileCalledWith.removeAll()
    }
}
