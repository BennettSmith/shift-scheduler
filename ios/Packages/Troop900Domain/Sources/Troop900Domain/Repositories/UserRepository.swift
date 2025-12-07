import Foundation

/// Protocol for user data persistence operations.
public protocol UserRepository: Sendable {
    /// Get a user by ID.
    /// - Parameter id: The user's ID.
    /// - Returns: The user entity.
    func getUser(id: String) async throws -> User
    
    /// Get a user by email address.
    /// - Parameter email: The user's email address.
    /// - Returns: The user entity, or nil if not found.
    func getUserByEmail(email: String) async throws -> User?
    
    /// Get a user by their claim code.
    /// - Parameter code: The claim code.
    /// - Returns: The user entity, or nil if not found.
    func getUserByClaimCode(code: String) async throws -> User?
    
    /// Get users by household ID.
    /// - Parameter householdId: The household ID.
    /// - Returns: An array of users in the household.
    func getUsersByHousehold(householdId: String) async throws -> [User]
    
    /// Observe a user by ID for real-time updates.
    /// - Parameter id: The user's ID.
    /// - Returns: A stream of user entities.
    func observeUser(id: String) -> AsyncThrowingStream<User, Error>
    
    /// Update a user entity.
    /// - Parameter user: The user entity to update.
    func updateUser(_ user: User) async throws
    
    /// Create a new user entity.
    /// - Parameter user: The user entity to create.
    /// - Returns: The created user's ID.
    func createUser(_ user: User) async throws -> String
}
