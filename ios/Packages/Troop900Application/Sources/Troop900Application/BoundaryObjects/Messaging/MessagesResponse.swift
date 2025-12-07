import Foundation
import Troop900Domain

/// Response containing messages for a user.
public struct MessagesResponse: Sendable, Equatable {
    public let messages: [Message]
    public let unreadCount: Int
    
    public init(messages: [Message], unreadCount: Int) {
        self.messages = messages
        self.unreadCount = unreadCount
    }
}
