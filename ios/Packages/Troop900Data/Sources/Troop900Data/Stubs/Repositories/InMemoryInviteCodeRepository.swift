import Foundation
import Troop900Domain

/// In-memory implementation of InviteCodeRepository for testing and local development.
public final class InMemoryInviteCodeRepository: InviteCodeRepository, @unchecked Sendable {
    private var inviteCodes: [String: InviteCode] = [:]
    private var inviteCodesByCode: [String: String] = [:]
    private var inviteCodesByHousehold: [String: Set<String>] = [:]
    private let lock = AsyncLock()
    
    public init(initialInviteCodes: [InviteCode] = []) {
        for inviteCode in initialInviteCodes {
            inviteCodes[inviteCode.id] = inviteCode
            inviteCodesByCode[inviteCode.code] = inviteCode.id
            inviteCodesByHousehold[inviteCode.householdId, default: []].insert(inviteCode.id)
        }
    }
    
    public func getInviteCode(id: String) async throws -> InviteCode {
        lock.lock()
        defer { lock.unlock() }
        guard let inviteCode = inviteCodes[id] else {
            throw DomainError.inviteCodeNotFound
        }
        return inviteCode
    }
    
    public func getInviteCodeByCode(code: String) async throws -> InviteCode? {
        lock.lock()
        defer { lock.unlock() }
        guard let inviteCodeId = inviteCodesByCode[code] else {
            return nil
        }
        return inviteCodes[inviteCodeId]
    }
    
    public func getInviteCodesForHousehold(householdId: String) async throws -> [InviteCode] {
        lock.lock()
        defer { lock.unlock() }
        guard let inviteCodeIds = inviteCodesByHousehold[householdId] else {
            return []
        }
        return inviteCodeIds.compactMap { inviteCodes[$0] }
    }
    
    public func updateInviteCode(_ inviteCode: InviteCode) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard inviteCodes[inviteCode.id] != nil else {
            throw DomainError.inviteCodeNotFound
        }
        
        // Remove old code mapping
        if let oldInviteCode = inviteCodes[inviteCode.id] {
            inviteCodesByCode.removeValue(forKey: oldInviteCode.code)
            inviteCodesByHousehold[oldInviteCode.householdId]?.remove(inviteCode.id)
        }
        
        // Add new mappings
        inviteCodes[inviteCode.id] = inviteCode
        inviteCodesByCode[inviteCode.code] = inviteCode.id
        inviteCodesByHousehold[inviteCode.householdId, default: []].insert(inviteCode.id)
    }
    
    public func createInviteCode(_ inviteCode: InviteCode) async throws -> String {
        lock.lock()
        defer { lock.unlock() }
        
        guard inviteCodes[inviteCode.id] == nil else {
            throw DomainError.invalidInput("InviteCode with id \(inviteCode.id) already exists")
        }
        
        inviteCodes[inviteCode.id] = inviteCode
        inviteCodesByCode[inviteCode.code] = inviteCode.id
        inviteCodesByHousehold[inviteCode.householdId, default: []].insert(inviteCode.id)
        
        return inviteCode.id
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        inviteCodes.removeAll()
        inviteCodesByCode.removeAll()
        inviteCodesByHousehold.removeAll()
    }
    
    public func getAllInviteCodes() -> [InviteCode] {
        lock.lock()
        defer { lock.unlock() }
        return Array(inviteCodes.values)
    }
}
