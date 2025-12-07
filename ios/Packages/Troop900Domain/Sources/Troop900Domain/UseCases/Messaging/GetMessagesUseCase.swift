import Foundation

/// Protocol for getting messages for a user.
public protocol GetMessagesUseCaseProtocol: Sendable {
    func execute(userId: String) async throws -> MessagesResponse
}

/// Use case for retrieving messages for a user.
public final class GetMessagesUseCase: GetMessagesUseCaseProtocol, Sendable {
    private let messageRepository: MessageRepository
    
    public init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    public func execute(userId: String) async throws -> MessagesResponse {
        let messages = try await messageRepository.getMessagesForUser(userId: userId)
        let unreadCount = messages.filter { !$0.isRead }.count
        
        return MessagesResponse(messages: messages, unreadCount: unreadCount)
    }
}
