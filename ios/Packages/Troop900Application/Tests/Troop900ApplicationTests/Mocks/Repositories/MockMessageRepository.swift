import Foundation
import Troop900Domain

/// Mock implementation of MessageRepository for testing
public final class MockMessageRepository: MessageRepository, @unchecked Sendable {
    
    // MARK: - In-Memory Storage
    
    /// Messages stored by ID
    public var messagesById: [String: Message] = [:]
    
    // MARK: - Configurable Results
    
    public var getMessageResult: Result<Message, Error>?
    public var getMessagesForUserResult: Result<[Message], Error>?
    public var getUnreadMessagesForUserResult: Result<[Message], Error>?
    public var createMessageResult: Result<String, Error>?
    public var markMessageAsReadError: Error?
    public var deleteMessageError: Error?
    
    // MARK: - Call Tracking
    
    public var getMessageCallCount = 0
    public var getMessageCalledWith: [String] = []
    
    public var getMessagesForUserCallCount = 0
    public var getMessagesForUserCalledWith: [String] = []
    
    public var getUnreadMessagesForUserCallCount = 0
    public var getUnreadMessagesForUserCalledWith: [String] = []
    
    public var createMessageCallCount = 0
    public var createMessageCalledWith: [Message] = []
    
    public var markMessageAsReadCallCount = 0
    public var markMessageAsReadCalledWith: [String] = []
    
    public var deleteMessageCallCount = 0
    public var deleteMessageCalledWith: [String] = []
    
    // MARK: - MessageRepository Implementation
    
    public func getMessage(id: String) async throws -> Message {
        getMessageCallCount += 1
        getMessageCalledWith.append(id)
        
        if let result = getMessageResult {
            return try result.get()
        }
        
        guard let message = messagesById[id] else {
            throw DomainError.messageNotFound
        }
        return message
    }
    
    public func getMessagesForUser(userId: String) async throws -> [Message] {
        getMessagesForUserCallCount += 1
        getMessagesForUserCalledWith.append(userId)
        
        if let result = getMessagesForUserResult {
            return try result.get()
        }
        
        // Return all messages (in real impl would filter by target audience/users)
        return Array(messagesById.values).sorted { $0.sentAt > $1.sentAt }
    }
    
    public func getUnreadMessagesForUser(userId: String) async throws -> [Message] {
        getUnreadMessagesForUserCallCount += 1
        getUnreadMessagesForUserCalledWith.append(userId)
        
        if let result = getUnreadMessagesForUserResult {
            return try result.get()
        }
        
        return messagesById.values.filter { !$0.isRead }
            .sorted { $0.sentAt > $1.sentAt }
    }
    
    public func observeMessagesForUser(userId: String) -> AsyncThrowingStream<[Message], Error> {
        AsyncThrowingStream { continuation in
            let messages = Array(messagesById.values).sorted { $0.sentAt > $1.sentAt }
            continuation.yield(messages)
            continuation.finish()
        }
    }
    
    public func markMessageAsRead(id: String) async throws {
        markMessageAsReadCallCount += 1
        markMessageAsReadCalledWith.append(id)
        
        if let error = markMessageAsReadError {
            throw error
        }
        
        // Update message in storage (would need mutable version)
        // For testing, we track that it was called
    }
    
    public func createMessage(_ message: Message) async throws -> String {
        createMessageCallCount += 1
        createMessageCalledWith.append(message)
        
        if let result = createMessageResult {
            return try result.get()
        }
        
        messagesById[message.id] = message
        return message.id
    }
    
    public func deleteMessage(id: String) async throws {
        deleteMessageCallCount += 1
        deleteMessageCalledWith.append(id)
        
        if let error = deleteMessageError {
            throw error
        }
        
        messagesById.removeValue(forKey: id)
    }
    
    // MARK: - Test Helpers
    
    /// Resets all state and call tracking
    public func reset() {
        messagesById.removeAll()
        getMessageResult = nil
        getMessagesForUserResult = nil
        getUnreadMessagesForUserResult = nil
        createMessageResult = nil
        markMessageAsReadError = nil
        deleteMessageError = nil
        getMessageCallCount = 0
        getMessageCalledWith.removeAll()
        getMessagesForUserCallCount = 0
        getMessagesForUserCalledWith.removeAll()
        getUnreadMessagesForUserCallCount = 0
        getUnreadMessagesForUserCalledWith.removeAll()
        createMessageCallCount = 0
        createMessageCalledWith.removeAll()
        markMessageAsReadCallCount = 0
        markMessageAsReadCalledWith.removeAll()
        deleteMessageCallCount = 0
        deleteMessageCalledWith.removeAll()
    }
}
