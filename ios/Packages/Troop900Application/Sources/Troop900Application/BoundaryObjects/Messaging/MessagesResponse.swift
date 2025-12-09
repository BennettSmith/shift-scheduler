import Foundation

/// Info about a message for display.
public struct MessageInfo: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let body: String
    public let priority: MessagePriorityType
    public let sentAt: Date
    public let isRead: Bool
    
    public init(id: String, title: String, body: String, priority: MessagePriorityType, sentAt: Date, isRead: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.priority = priority
        self.sentAt = sentAt
        self.isRead = isRead
    }
}

/// Response containing messages for a user.
public struct MessagesResponse: Sendable, Equatable {
    public let messages: [MessageInfo]
    public let unreadCount: Int
    
    public init(messages: [MessageInfo], unreadCount: Int) {
        self.messages = messages
        self.unreadCount = unreadCount
    }
}
