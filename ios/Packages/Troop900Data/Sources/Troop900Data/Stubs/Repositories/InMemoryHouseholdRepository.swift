import Foundation
import Troop900Domain

/// In-memory implementation of HouseholdRepository for testing and local development.
public final class InMemoryHouseholdRepository: HouseholdRepository, @unchecked Sendable {
    private var households: [String: Household] = [:]
    private var householdsByLinkCode: [String: String] = [:]
    private var householdsByManager: [UserId: Set<String>] = [:]
    private let lock = AsyncLock()
    
    public init(initialHouseholds: [Household] = []) {
        for household in initialHouseholds {
            households[household.id] = household
            if let linkCode = household.linkCode {
                householdsByLinkCode[linkCode] = household.id
            }
            for managerId in household.managers {
                if let userId = try? UserId(unchecked: managerId) {
                    householdsByManager[userId, default: []].insert(household.id)
                }
            }
        }
    }
    
    public func getHousehold(id: String) async throws -> Household {
        lock.lock()
        defer { lock.unlock() }
        guard let household = households[id] else {
            throw DomainError.householdNotFound
        }
        return household
    }
    
    public func getHouseholdByLinkCode(linkCode: String) async throws -> Household? {
        lock.lock()
        defer { lock.unlock() }
        guard let householdId = householdsByLinkCode[linkCode] else {
            return nil
        }
        return households[householdId]
    }
    
    public func getHouseholdsManagedByUser(userId: UserId) async throws -> [Household] {
        lock.lock()
        defer { lock.unlock() }
        guard let householdIds = householdsByManager[userId] else {
            return []
        }
        return householdIds.compactMap { households[$0] }
    }
    
    public func observeHousehold(id: String) -> AsyncThrowingStream<Household, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let household = try await getHousehold(id: id)
                    continuation.yield(household)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateHousehold(_ household: Household) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard households[household.id] != nil else {
            throw DomainError.householdNotFound
        }
        
        // Remove old link code mapping
        if let oldHousehold = households[household.id], let oldLinkCode = oldHousehold.linkCode {
            householdsByLinkCode.removeValue(forKey: oldLinkCode)
        }
        
        // Remove old manager mappings
        if let oldHousehold = households[household.id] {
            for managerId in oldHousehold.managers {
                if let userId = try? UserId(unchecked: managerId) {
                    householdsByManager[userId]?.remove(household.id)
                }
            }
        }
        
        // Add new mappings
        households[household.id] = household
        if let linkCode = household.linkCode {
            householdsByLinkCode[linkCode] = household.id
        }
        for managerId in household.managers {
            if let userId = try? UserId(unchecked: managerId) {
                householdsByManager[userId, default: []].insert(household.id)
            }
        }
    }
    
    public func createHousehold(_ household: Household) async throws -> String {
        lock.lock()
        defer { lock.unlock() }
        
        guard households[household.id] == nil else {
            throw DomainError.invalidInput("Household with id \(household.id) already exists")
        }
        
        households[household.id] = household
        if let linkCode = household.linkCode {
            householdsByLinkCode[linkCode] = household.id
        }
        for managerId in household.managers {
            if let userId = try? UserId(unchecked: managerId) {
                householdsByManager[userId, default: []].insert(household.id)
            }
        }
        
        return household.id
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        households.removeAll()
        householdsByLinkCode.removeAll()
        householdsByManager.removeAll()
    }
    
    public func getAllHouseholds() -> [Household] {
        lock.lock()
        defer { lock.unlock() }
        return Array(households.values)
    }
}
