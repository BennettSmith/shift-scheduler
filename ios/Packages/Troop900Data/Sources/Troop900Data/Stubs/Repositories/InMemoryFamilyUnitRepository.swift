import Foundation
import Troop900Domain

/// In-memory implementation of FamilyUnitRepository for testing and local development.
public final class InMemoryFamilyUnitRepository: FamilyUnitRepository, @unchecked Sendable {
    private var familyUnits: [String: FamilyUnit] = [:]
    private var familyUnitsByHousehold: [String: Set<String>] = [:]
    private let lock = AsyncLock()
    
    public init(initialFamilyUnits: [FamilyUnit] = []) {
        for familyUnit in initialFamilyUnits {
            familyUnits[familyUnit.id] = familyUnit
            familyUnitsByHousehold[familyUnit.householdId, default: []].insert(familyUnit.id)
        }
    }
    
    public func getFamilyUnit(id: String) async throws -> FamilyUnit {
        lock.lock()
        defer { lock.unlock() }
        guard let familyUnit = familyUnits[id] else {
            throw DomainError.invalidInput("FamilyUnit with id \(id) not found")
        }
        return familyUnit
    }
    
    public func getFamilyUnitsInHousehold(householdId: String) async throws -> [FamilyUnit] {
        lock.lock()
        defer { lock.unlock() }
        guard let familyUnitIds = familyUnitsByHousehold[householdId] else {
            return []
        }
        return familyUnitIds.compactMap { familyUnits[$0] }
    }
    
    public func observeFamilyUnit(id: String) -> AsyncThrowingStream<FamilyUnit, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let familyUnit = try await getFamilyUnit(id: id)
                    continuation.yield(familyUnit)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateFamilyUnit(_ familyUnit: FamilyUnit) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard familyUnits[familyUnit.id] != nil else {
            throw DomainError.invalidInput("FamilyUnit with id \(familyUnit.id) not found")
        }
        
        // Remove old household mapping
        if let oldFamilyUnit = familyUnits[familyUnit.id] {
            familyUnitsByHousehold[oldFamilyUnit.householdId]?.remove(familyUnit.id)
        }
        
        // Add new mapping
        familyUnits[familyUnit.id] = familyUnit
        familyUnitsByHousehold[familyUnit.householdId, default: []].insert(familyUnit.id)
    }
    
    public func createFamilyUnit(_ familyUnit: FamilyUnit) async throws -> String {
        lock.lock()
        defer { lock.unlock() }
        
        guard familyUnits[familyUnit.id] == nil else {
            throw DomainError.invalidInput("FamilyUnit with id \(familyUnit.id) already exists")
        }
        
        familyUnits[familyUnit.id] = familyUnit
        familyUnitsByHousehold[familyUnit.householdId, default: []].insert(familyUnit.id)
        
        return familyUnit.id
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        familyUnits.removeAll()
        familyUnitsByHousehold.removeAll()
    }
    
    public func getAllFamilyUnits() -> [FamilyUnit] {
        lock.lock()
        defer { lock.unlock() }
        return Array(familyUnits.values)
    }
}
