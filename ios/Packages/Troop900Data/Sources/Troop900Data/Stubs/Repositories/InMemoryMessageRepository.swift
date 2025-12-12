import Foundation
import Troop900Domain

/// In-memory implementation of MessageRepository for testing and local development.
public final class InMemoryMessageRepository: MessageRepository, @unchecked Sendable {
    private var messages: [String: Message] = [:]
    private var messagesByUser: [String: Set<String>] = [:]
    private let lock = AsyncLock()
    
    public init(initialMessages: [Message] = []) {
        for message in initialMessages {
            messages[message.id] = message
            // Add to all target users
            if let targetUserIds = message.targetUserIds {
                for userId in targetUserIds {
                    messagesByUser[userId, default: []].insert(message.id)
                }
            }
            // Note: Would also need to handle targetHouseholdIds and targetAudience
            // For simplicity, only handling direct targetUserIds
        }
    }
    
    public func getMessage(id: String) async throws -> Message {
        lock.lock()
        defer { lock.unlock() }
        guard let message = messages[id] else {
            throw DomainError.messageNotFound
        }
        return message
    }
    
    public func getMessagesForUser(userId: String) async throws -> [Message] {
        lock.lock()
        defer { lock.unlock() }
        guard let messageIds = messagesByUser[userId] else {
            return []
        }
        return messageIds.compactMap { messages[$0] }
    }
    
    public func getUnreadMessagesForUser(userId: String) async throws -> [Message] {
        lock.lock()
        defer { lock.unlock() }
        guard let messageIds = messagesByUser[userId] else {
            return []
        }
        return messageIds.compactMap { messages[$0] }.filter { !$0.isRead }
    }
    
    public func observeMessagesForUser(userId: String) -> AsyncThrowingStream<[Message], Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let messages = try await getMessagesForUser(userId: userId)
                    continuation.yield(messages)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    public func markMessageAsRead(id: String) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard var message = messages[id] else {
            throw DomainError.messageNotFound
        }
        
        // Create updated message with isRead = true
        let updatedMessage = Message(
            id: message.id,
            title: message.title,
            body: message.body,
            targetAudience: message.targetAudience,
            targetUserIds: message.targetUserIds,
            targetHouseholdIds: message.targetHouseholdIds,
            senderId: message.senderId,
            sentAt: message.sentAt,
            priority: message.priority,
            isRead: true
        )
        
        messages[id] = updatedMessage
    }
    
    public func createMessage(_ message: Message) async throws -> String {
        lock.lock()
        defer { lock.unlock() }
        
        guard messages[message.id] == nil else {
            throw DomainError.invalidInput("Message with id \(message.id) already exists")
        }
        
        messages[message.id] = message
        
        // Add to target users
        if let targetUserIds = message.targetUserIds {
            for userId in targetUserIds {
                messagesByUser[userId, default: []].insert(message.id)
            }
        }
        
        return message.id
    }
    
    public func deleteMessage(id: String) async throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard let message = messages[id] else {
            throw DomainError.messageNotFound
        }
        
        messages.removeValue(forKey: id)
        
        // Remove from user mappings
        if let targetUserIds = message.targetUserIds {
            for userId in targetUserIds {
                messagesByUser[userId]?.remove(id)
            }
        }
    }
    
    // MARK: - Test Helpers
    
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        messages.removeAll()
        messagesByUser.removeAll()
    }
    
    public func getAllMessages() -> [Message] {
        lock.lock()
        defer { lock.unlock() }
        return Array(messages.values)
    }
}
