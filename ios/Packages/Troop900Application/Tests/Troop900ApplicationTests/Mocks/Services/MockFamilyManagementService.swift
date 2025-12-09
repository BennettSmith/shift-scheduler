import Foundation
import Troop900Domain

/// Mock implementation of FamilyManagementService for testing
public final class MockFamilyManagementService: FamilyManagementService, @unchecked Sendable {
    
    // MARK: - Configurable Results
    
    public var addFamilyMemberResult: Result<AddFamilyMemberResult, Error>?
    public var linkScoutToHouseholdResult: Result<LinkScoutResult, Error>?
    public var regenerateHouseholdLinkCodeResult: Result<String, Error>?
    public var deactivateFamilyError: Error?
    
    // MARK: - Call Tracking
    
    public var addFamilyMemberCallCount = 0
    public var addFamilyMemberCalledWith: [AddFamilyMemberRequest] = []
    
    public var linkScoutToHouseholdCallCount = 0
    public var linkScoutToHouseholdCalledWith: [(scoutId: UserId, linkCode: String)] = []
    
    public var regenerateHouseholdLinkCodeCallCount = 0
    public var regenerateHouseholdLinkCodeCalledWith: [String] = []
    
    public var deactivateFamilyCallCount = 0
    public var deactivateFamilyCalledWith: [FamilyDeactivationRequest] = []
    
    // MARK: - FamilyManagementService Implementation
    
    public func addFamilyMember(request: AddFamilyMemberRequest) async throws -> AddFamilyMemberResult {
        addFamilyMemberCallCount += 1
        addFamilyMemberCalledWith.append(request)
        
        if let result = addFamilyMemberResult {
            return try result.get()
        }
        
        // Default success response
        return AddFamilyMemberResult(
            success: true,
            userId: UserId(unchecked: "user-\(UUID().uuidString.prefix(8))"),
            claimCode: "CLAIMCODE",
            message: "Family member added successfully"
        )
    }
    
    public func linkScoutToHousehold(scoutId: UserId, linkCode: String) async throws -> LinkScoutResult {
        linkScoutToHouseholdCallCount += 1
        linkScoutToHouseholdCalledWith.append((scoutId, linkCode))
        
        if let result = linkScoutToHouseholdResult {
            return try result.get()
        }
        
        // Default success response
        return LinkScoutResult(
            success: true,
            householdId: "household-\(UUID().uuidString.prefix(8))",
            message: "Scout linked successfully"
        )
    }
    
    public func regenerateHouseholdLinkCode(householdId: String) async throws -> String {
        regenerateHouseholdLinkCodeCallCount += 1
        regenerateHouseholdLinkCodeCalledWith.append(householdId)
        
        if let result = regenerateHouseholdLinkCodeResult {
            return try result.get()
        }
        
        // Generate a random link code
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
    
    public func deactivateFamily(request: FamilyDeactivationRequest) async throws {
        deactivateFamilyCallCount += 1
        deactivateFamilyCalledWith.append(request)
        
        if let error = deactivateFamilyError {
            throw error
        }
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        addFamilyMemberResult = nil
        linkScoutToHouseholdResult = nil
        regenerateHouseholdLinkCodeResult = nil
        deactivateFamilyError = nil
        addFamilyMemberCallCount = 0
        addFamilyMemberCalledWith.removeAll()
        linkScoutToHouseholdCallCount = 0
        linkScoutToHouseholdCalledWith.removeAll()
        regenerateHouseholdLinkCodeCallCount = 0
        regenerateHouseholdLinkCodeCalledWith.removeAll()
        deactivateFamilyCallCount = 0
        deactivateFamilyCalledWith.removeAll()
    }
}
