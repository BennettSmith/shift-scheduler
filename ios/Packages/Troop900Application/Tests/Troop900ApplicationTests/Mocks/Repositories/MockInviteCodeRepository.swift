import Foundation
import Troop900Domain

/// Mock implementation of InviteCodeRepository for testing
public final class MockInviteCodeRepository: InviteCodeRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Invite codes stored by ID
    public var inviteCodesById: [String: InviteCode] = [:]
    
    /// Invite codes stored by code string (for lookup)
    public var inviteCodesByCode: [String: InviteCode] = [:]
    
    // MARK: - Configurable Results
    
    public var getInviteCodeResult: Result<InviteCode, Error>?
    public var getInviteCodeByCodeResult: Result<InviteCode?, Error>?
    public var getInviteCodesForHouseholdResult: Result<[InviteCode], Error>?
    public var createInviteCodeResult: Result<String, Error>?
    public var updateInviteCodeError: Error?
    
    // MARK: - Call Tracking
    
    public var getInviteCodeCallCount = 0
    public var getInviteCodeCalledWith: [String] = []
    
    public var getInviteCodeByCodeCallCount = 0
    public var getInviteCodeByCodeCalledWith: [String] = []
    
    public var getInviteCodesForHouseholdCallCount = 0
    public var getInviteCodesForHouseholdCalledWith: [String] = []
    
    public var createInviteCodeCallCount = 0
    public var createInviteCodeCalledWith: [InviteCode] = []
    
    public var updateInviteCodeCallCount = 0
    public var updateInviteCodeCalledWith: [InviteCode] = []
    
    // MARK: - InviteCodeRepository Implementation
    
    public func getInviteCode(id: String) async throws -> InviteCode {
        getInviteCodeCallCount += 1
        getInviteCodeCalledWith.append(id)
        
        if let result = getInviteCodeResult {
            return try result.get()
        }
        
        guard let inviteCode = inviteCodesById[id] else {
            throw DomainError.inviteCodeNotFound
        }
        return inviteCode
    }
    
    public func getInviteCodeByCode(code: String) async throws -> InviteCode? {
        getInviteCodeByCodeCallCount += 1
        getInviteCodeByCodeCalledWith.append(code)
        
        if let result = getInviteCodeByCodeResult {
            return try result.get()
        }
        
        return inviteCodesByCode[code]
    }
    
    public func getInviteCodesForHousehold(householdId: String) async throws -> [InviteCode] {
        getInviteCodesForHouseholdCallCount += 1
        getInviteCodesForHouseholdCalledWith.append(householdId)
        
        if let result = getInviteCodesForHouseholdResult {
            return try result.get()
        }
        
        return inviteCodesById.values.filter { $0.householdId == householdId }
    }
    
    public func updateInviteCode(_ inviteCode: InviteCode) async throws {
        updateInviteCodeCallCount += 1
        updateInviteCodeCalledWith.append(inviteCode)
        
        if let error = updateInviteCodeError {
            throw error
        }
        
        inviteCodesById[inviteCode.id] = inviteCode
        inviteCodesByCode[inviteCode.code] = inviteCode
    }
    
    public func createInviteCode(_ inviteCode: InviteCode) async throws -> String {
        createInviteCodeCallCount += 1
        createInviteCodeCalledWith.append(inviteCode)
        
        if let result = createInviteCodeResult {
            return try result.get()
        }
        
        inviteCodesById[inviteCode.id] = inviteCode
        inviteCodesByCode[inviteCode.code] = inviteCode
        return inviteCode.id
    }
    
    // MARK: - Test Helpers
    
    /// Adds an invite code to all appropriate indexes
    public func addInviteCode(_ inviteCode: InviteCode) {
        inviteCodesById[inviteCode.id] = inviteCode
        inviteCodesByCode[inviteCode.code] = inviteCode
    }
    
    /// Resets all state and call tracking
    public func reset() {
        inviteCodesById.removeAll()
        inviteCodesByCode.removeAll()
        getInviteCodeResult = nil
        getInviteCodeByCodeResult = nil
        getInviteCodesForHouseholdResult = nil
        createInviteCodeResult = nil
        updateInviteCodeError = nil
        getInviteCodeCallCount = 0
        getInviteCodeCalledWith.removeAll()
        getInviteCodeByCodeCallCount = 0
        getInviteCodeByCodeCalledWith.removeAll()
        getInviteCodesForHouseholdCallCount = 0
        getInviteCodesForHouseholdCalledWith.removeAll()
        createInviteCodeCallCount = 0
        createInviteCodeCalledWith.removeAll()
        updateInviteCodeCallCount = 0
        updateInviteCodeCalledWith.removeAll()
    }
}
