import Foundation
import Troop900Domain

/// In-memory implementation of UserRepository for testing and local development.
public final class InMemoryUserRepository: UserRepository, @unchecked Sendable {
    private var users: [UserId: User] = [:]
    private var usersByEmail: [String: UserId] = [:]
    private var usersByClaimCode: [String: UserId] = [:]
    private var usersByHousehold: [String: Set<UserId>] = [:]
    private let lock = AsyncLock()
    
    public init(initialUsers: [User] = []) {
        for user in initialUsers {
            users[user.id] = user
            usersByEmail[user.email.lowercased()] = user.id
            if let claimCode = user.claimCode {
                usersByClaimCode[claimCode] = user.id
            }
            for householdId in user.households {
                usersByHousehold[householdId, default: []].insert(user.id)
            }
        }
    }
    
    public func getUser(id: UserId) async throws -> User {
        lock.lock()
        defer { lock.unlock() }
        guard let user = users[id] else {
            throw DomainError.userNotFound
        }
        return user
    }
    
    public func getUserByEmail(email: String) async throws -> User? {
        lock.lock()
        defer { lock.unlock() }
        guard let userId = usersByEmail[email.lowercased()] else {
            return nil
        }
        return users[userId]
    }
    
    public func getUserByClaimCode(code: String) async throws -> User? {
        lock.lock()
        defer { lock.unlock() }
        guard let userId = usersByClaimCode[code] else {
            return nil
        }
        return users[userId]
    }
    
    public func getUsersByHousehold(householdId: String) async throws -> [User] {
        lock.lock()
        defer { lock.unlock() }
        guard let userIds = usersByHousehold[householdId] else {
            return []
        }
        return userIds.compactMap { users[$0] }
    }
    
    public func observeUser(id: UserId) -> AsyncThrowingStream<User, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let user = try await getUser(id: id)
                    continuation.yield(user)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func updateUser(_ user: User) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard users[user.id] != nil else {
            throw DomainError.userNotFound
        }
        
        // Remove old email/claimCode mappings
        if let oldUser = users[user.id] {
            usersByEmail.removeValue(forKey: oldUser.email.lowercased())
            if let oldClaimCode = oldUser.claimCode {
                usersByClaimCode.removeValue(forKey: oldClaimCode)
            }
            for householdId in oldUser.households {
                usersByHousehold[householdId]?.remove(user.id)
            }
        }
        
        // Add new mappings
        users[user.id] = user
        usersByEmail[user.email.lowercased()] = user.id
        if let claimCode = user.claimCode {
            usersByClaimCode[claimCode] = user.id
        }
        for householdId in user.households {
            usersByHousehold[householdId, default: []].insert(user.id)
        }
    }
    
    public func createUser(_ user: User) async throws -> UserId {
        lock.lock()
        defer { lock.unlock() }
        
        guard users[user.id] == nil else {
            throw DomainError.userAlreadyExists
        }
        
        users[user.id] = user
        usersByEmail[user.email.lowercased()] = user.id
        if let claimCode = user.claimCode {
            usersByClaimCode[claimCode] = user.id
        }
        for householdId in user.households {
            usersByHousehold[householdId, default: []].insert(user.id)
        }
        
        return user.id
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        users.removeAll()
        usersByEmail.removeAll()
        usersByClaimCode.removeAll()
        usersByHousehold.removeAll()
    }
    
    public func getAllUsers() -> [User] {
        lock.lock()
        defer { lock.unlock() }
        return Array(users.values)
    }
}
