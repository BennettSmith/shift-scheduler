import Foundation

/// Protocol for message data persistence operations.
public protocol MessageRepository: Sendable {
    /// Get a message by ID.
    /// - Parameter id: The message's ID.
    /// - Returns: The message entity.
    func getMessage(id: String) async throws -> Message
    
    /// Get all messages for a user.
    /// - Parameter userId: The user's ID.
    /// - Returns: An array of messages for the user.
    func getMessagesForUser(userId: String) async throws -> [Message]
    
    /// Get unread messages for a user.
    /// - Parameter userId: The user's ID.
    /// - Returns: An array of unread messages for the user.
    func getUnreadMessagesForUser(userId: String) async throws -> [Message]
    
    /// Observe messages for a user for real-time updates.
    /// - Parameter userId: The user's ID.
    /// - Returns: A stream of message arrays.
    func observeMessagesForUser(userId: String) -> AsyncThrowingStream<[Message], Error>
    
    /// Mark a message as read.
    /// - Parameter id: The message's ID.
    func markMessageAsRead(id: String) async throws
    
    /// Create a new message entity.
    /// - Parameter message: The message entity to create.
    /// - Returns: The created message's ID.
    func createMessage(_ message: Message) async throws -> String
    
    /// Delete a message by ID.
    /// - Parameter id: The message's ID.
    func deleteMessage(id: String) async throws
}
