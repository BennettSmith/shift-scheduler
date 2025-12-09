import Foundation
import Troop900Domain

/// Mock implementation of HouseholdRepository for testing
public final class MockHouseholdRepository: HouseholdRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Households stored by ID
    public var householdsById: [String: Household] = [:]
    
    /// Households stored by link code (for lookup)
    public var householdsByLinkCode: [String: Household] = [:]
    
    // MARK: - Configurable Results
    
    public var getHouseholdResult: Result<Household, Error>?
    public var getHouseholdByLinkCodeResult: Result<Household?, Error>?
    public var getHouseholdsManagedByUserResult: Result<[Household], Error>?
    public var createHouseholdResult: Result<String, Error>?
    public var updateHouseholdError: Error?
    
    // MARK: - Call Tracking
    
    public var getHouseholdCallCount = 0
    public var getHouseholdCalledWith: [String] = []
    
    public var getHouseholdByLinkCodeCallCount = 0
    public var getHouseholdByLinkCodeCalledWith: [String] = []
    
    public var getHouseholdsManagedByUserCallCount = 0
    public var getHouseholdsManagedByUserCalledWith: [UserId] = []
    
    public var createHouseholdCallCount = 0
    public var createHouseholdCalledWith: [Household] = []
    
    public var updateHouseholdCallCount = 0
    public var updateHouseholdCalledWith: [Household] = []
    
    // MARK: - HouseholdRepository Implementation
    
    public func getHousehold(id: String) async throws -> Household {
        getHouseholdCallCount += 1
        getHouseholdCalledWith.append(id)
        
        if let result = getHouseholdResult {
            return try result.get()
        }
        
        guard let household = householdsById[id] else {
            throw DomainError.householdNotFound
        }
        return household
    }
    
    public func getHouseholdByLinkCode(linkCode: String) async throws -> Household? {
        getHouseholdByLinkCodeCallCount += 1
        getHouseholdByLinkCodeCalledWith.append(linkCode)
        
        if let result = getHouseholdByLinkCodeResult {
            return try result.get()
        }
        
        return householdsByLinkCode[linkCode]
    }
    
    public func getHouseholdsManagedByUser(userId: UserId) async throws -> [Household] {
        getHouseholdsManagedByUserCallCount += 1
        getHouseholdsManagedByUserCalledWith.append(userId)
        
        if let result = getHouseholdsManagedByUserResult {
            return try result.get()
        }
        
        return householdsById.values.filter { $0.managers.contains(userId.value) }
    }
    
    public func observeHousehold(id: String) -> AsyncThrowingStream<Household, Error> {
        AsyncThrowingStream { continuation in
            if let household = householdsById[id] {
                continuation.yield(household)
            }
            continuation.finish()
        }
    }
    
    public func updateHousehold(_ household: Household) async throws {
        updateHouseholdCallCount += 1
        updateHouseholdCalledWith.append(household)
        
        if let error = updateHouseholdError {
            throw error
        }
        
        // Remove old link code mapping if it changed
        if let existingHousehold = householdsById[household.id],
           let oldLinkCode = existingHousehold.linkCode,
           oldLinkCode != household.linkCode {
            householdsByLinkCode.removeValue(forKey: oldLinkCode)
        }
        
        householdsById[household.id] = household
        if let linkCode = household.linkCode {
            householdsByLinkCode[linkCode] = household
        }
    }
    
    public func createHousehold(_ household: Household) async throws -> String {
        createHouseholdCallCount += 1
        createHouseholdCalledWith.append(household)
        
        if let result = createHouseholdResult {
            return try result.get()
        }
        
        householdsById[household.id] = household
        if let linkCode = household.linkCode {
            householdsByLinkCode[linkCode] = household
        }
        return household.id
    }
    
    // MARK: - Test Helpers
    
    /// Adds a household to all appropriate indexes
    public func addHousehold(_ household: Household) {
        householdsById[household.id] = household
        if let linkCode = household.linkCode {
            householdsByLinkCode[linkCode] = household
        }
    }
    
    /// Resets all state and call tracking
    public func reset() {
        householdsById.removeAll()
        householdsByLinkCode.removeAll()
        getHouseholdResult = nil
        getHouseholdByLinkCodeResult = nil
        getHouseholdsManagedByUserResult = nil
        createHouseholdResult = nil
        updateHouseholdError = nil
        getHouseholdCallCount = 0
        getHouseholdCalledWith.removeAll()
        getHouseholdByLinkCodeCallCount = 0
        getHouseholdByLinkCodeCalledWith.removeAll()
        getHouseholdsManagedByUserCallCount = 0
        getHouseholdsManagedByUserCalledWith.removeAll()
        createHouseholdCallCount = 0
        createHouseholdCalledWith.removeAll()
        updateHouseholdCallCount = 0
        updateHouseholdCalledWith.removeAll()
    }
}
