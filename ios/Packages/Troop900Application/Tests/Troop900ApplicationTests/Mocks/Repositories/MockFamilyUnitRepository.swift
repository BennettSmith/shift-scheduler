import Foundation
import Troop900Domain

/// Mock implementation of FamilyUnitRepository for testing
public final class MockFamilyUnitRepository: FamilyUnitRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Family units stored by ID
    public var familyUnitsById: [String: FamilyUnit] = [:]
    
    // MARK: - Configurable Results
    
    public var getFamilyUnitResult: Result<FamilyUnit, Error>?
    public var getFamilyUnitsInHouseholdResult: Result<[FamilyUnit], Error>?
    public var createFamilyUnitResult: Result<String, Error>?
    public var updateFamilyUnitError: Error?
    
    // MARK: - Call Tracking
    
    public var getFamilyUnitCallCount = 0
    public var getFamilyUnitCalledWith: [String] = []
    
    public var getFamilyUnitsInHouseholdCallCount = 0
    public var getFamilyUnitsInHouseholdCalledWith: [String] = []
    
    public var createFamilyUnitCallCount = 0
    public var createFamilyUnitCalledWith: [FamilyUnit] = []
    
    public var updateFamilyUnitCallCount = 0
    public var updateFamilyUnitCalledWith: [FamilyUnit] = []
    
    // MARK: - FamilyUnitRepository Implementation
    
    public func getFamilyUnit(id: String) async throws -> FamilyUnit {
        getFamilyUnitCallCount += 1
        getFamilyUnitCalledWith.append(id)
        
        if let result = getFamilyUnitResult {
            return try result.get()
        }
        
        guard let familyUnit = familyUnitsById[id] else {
            throw DomainError.operationFailed("Family unit not found")
        }
        return familyUnit
    }
    
    public func getFamilyUnitsInHousehold(householdId: String) async throws -> [FamilyUnit] {
        getFamilyUnitsInHouseholdCallCount += 1
        getFamilyUnitsInHouseholdCalledWith.append(householdId)
        
        if let result = getFamilyUnitsInHouseholdResult {
            return try result.get()
        }
        
        return familyUnitsById.values.filter { $0.householdId == householdId }
    }
    
    public func observeFamilyUnit(id: String) -> AsyncThrowingStream<FamilyUnit, Error> {
        AsyncThrowingStream { continuation in
            if let familyUnit = familyUnitsById[id] {
                continuation.yield(familyUnit)
            }
            continuation.finish()
        }
    }
    
    public func updateFamilyUnit(_ familyUnit: FamilyUnit) async throws {
        updateFamilyUnitCallCount += 1
        updateFamilyUnitCalledWith.append(familyUnit)
        
        if let error = updateFamilyUnitError {
            throw error
        }
        
        familyUnitsById[familyUnit.id] = familyUnit
    }
    
    public func createFamilyUnit(_ familyUnit: FamilyUnit) async throws -> String {
        createFamilyUnitCallCount += 1
        createFamilyUnitCalledWith.append(familyUnit)
        
        if let result = createFamilyUnitResult {
            return try result.get()
        }
        
        familyUnitsById[familyUnit.id] = familyUnit
        return familyUnit.id
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        familyUnitsById.removeAll()
        getFamilyUnitResult = nil
        getFamilyUnitsInHouseholdResult = nil
        createFamilyUnitResult = nil
        updateFamilyUnitError = nil
        getFamilyUnitCallCount = 0
        getFamilyUnitCalledWith.removeAll()
        getFamilyUnitsInHouseholdCallCount = 0
        getFamilyUnitsInHouseholdCalledWith.removeAll()
        createFamilyUnitCallCount = 0
        createFamilyUnitCalledWith.removeAll()
        updateFamilyUnitCallCount = 0
        updateFamilyUnitCalledWith.removeAll()
    }
}
