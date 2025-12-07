import Foundation
import Troop900Domain

/// Mock implementation of UserRepository for testing
public final class MockUserRepository: UserRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Users stored by ID
    public var usersById: [String: User] = [:]
    
    /// Users stored by email (for lookup)
    public var usersByEmail: [String: User] = [:]
    
    /// Users stored by claim code (for lookup)
    public var usersByClaimCode: [String: User] = [:]
    
    // MARK: - Configurable Results
    
    public var getUserResult: Result<User, Error>?
    public var getUserByEmailResult: Result<User?, Error>?
    public var getUserByClaimCodeResult: Result<User?, Error>?
    public var getUsersByHouseholdResult: Result<[User], Error>?
    public var createUserResult: Result<String, Error>?
    public var updateUserError: Error?
    
    // MARK: - Call Tracking
    
    public var getUserCallCount = 0
    public var getUserCalledWith: [String] = []
    
    public var getUserByEmailCallCount = 0
    public var getUserByEmailCalledWith: [String] = []
    
    public var getUserByClaimCodeCallCount = 0
    public var getUserByClaimCodeCalledWith: [String] = []
    
    public var getUsersByHouseholdCallCount = 0
    public var getUsersByHouseholdCalledWith: [String] = []
    
    public var createUserCallCount = 0
    public var createUserCalledWith: [User] = []
    
    public var updateUserCallCount = 0
    public var updateUserCalledWith: [User] = []
    
    // MARK: - UserRepository Implementation
    
    public func getUser(id: String) async throws -> User {
        getUserCallCount += 1
        getUserCalledWith.append(id)
        
        if let result = getUserResult {
            return try result.get()
        }
        
        guard let user = usersById[id] else {
            throw DomainError.userNotFound
        }
        return user
    }
    
    public func getUserByEmail(email: String) async throws -> User? {
        getUserByEmailCallCount += 1
        getUserByEmailCalledWith.append(email)
        
        if let result = getUserByEmailResult {
            return try result.get()
        }
        
        return usersByEmail[email.lowercased()]
    }
    
    public func getUserByClaimCode(code: String) async throws -> User? {
        getUserByClaimCodeCallCount += 1
        getUserByClaimCodeCalledWith.append(code)
        
        if let result = getUserByClaimCodeResult {
            return try result.get()
        }
        
        return usersByClaimCode[code]
    }
    
    public func getUsersByHousehold(householdId: String) async throws -> [User] {
        getUsersByHouseholdCallCount += 1
        getUsersByHouseholdCalledWith.append(householdId)
        
        if let result = getUsersByHouseholdResult {
            return try result.get()
        }
        
        return usersById.values.filter { $0.households.contains(householdId) }
    }
    
    public func observeUser(id: String) -> AsyncThrowingStream<User, Error> {
        AsyncThrowingStream { continuation in
            if let user = usersById[id] {
                continuation.yield(user)
            }
            continuation.finish()
        }
    }
    
    public func updateUser(_ user: User) async throws {
        updateUserCallCount += 1
        updateUserCalledWith.append(user)
        
        if let error = updateUserError {
            throw error
        }
        
        usersById[user.id] = user
        usersByEmail[user.email.lowercased()] = user
        if let claimCode = user.claimCode {
            usersByClaimCode[claimCode] = user
        }
    }
    
    public func createUser(_ user: User) async throws -> String {
        createUserCallCount += 1
        createUserCalledWith.append(user)
        
        if let result = createUserResult {
            return try result.get()
        }
        
        usersById[user.id] = user
        usersByEmail[user.email.lowercased()] = user
        if let claimCode = user.claimCode {
            usersByClaimCode[claimCode] = user
        }
        return user.id
    }
    
    // MARK: - Test Helpers
    
    /// Adds a user to all appropriate indexes
    public func addUser(_ user: User) {
        usersById[user.id] = user
        usersByEmail[user.email.lowercased()] = user
        if let claimCode = user.claimCode {
            usersByClaimCode[claimCode] = user
        }
    }
    
    /// Resets all state and call tracking
    public func reset() {
        usersById.removeAll()
        usersByEmail.removeAll()
        usersByClaimCode.removeAll()
        getUserResult = nil
        getUserByEmailResult = nil
        getUserByClaimCodeResult = nil
        getUsersByHouseholdResult = nil
        createUserResult = nil
        updateUserError = nil
        getUserCallCount = 0
        getUserCalledWith.removeAll()
        getUserByEmailCallCount = 0
        getUserByEmailCalledWith.removeAll()
        getUserByClaimCodeCallCount = 0
        getUserByClaimCodeCalledWith.removeAll()
        getUsersByHouseholdCallCount = 0
        getUsersByHouseholdCalledWith.removeAll()
        createUserCallCount = 0
        createUserCalledWith.removeAll()
        updateUserCallCount = 0
        updateUserCalledWith.removeAll()
    }
}
