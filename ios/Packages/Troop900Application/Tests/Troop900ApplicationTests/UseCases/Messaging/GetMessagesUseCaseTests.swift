import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("GetMessagesUseCase Tests")
struct GetMessagesUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockMessageRepository = MockMessageRepository()
    
    private var useCase: GetMessagesUseCase {
        GetMessagesUseCase(messageRepository: mockMessageRepository)
    }
    
    // MARK: - Helper Functions
    
    private func createMessage(
        id: String,
        title: String = "Test Message",
        isRead: Bool = false
    ) -> Message {
        Message(
            id: id,
            title: title,
            body: "Test body",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            senderId: "admin-1",
            sentAt: Date(),
            priority: .normal,
            isRead: isRead
        )
    }
    
    // MARK: - Success Tests
    
    @Test("Get messages succeeds and returns all messages")
    func getMessagesSucceeds() async throws {
        // Given
        let userId = "user-1"
        let message1 = createMessage(id: "msg-1", title: "First Message")
        let message2 = createMessage(id: "msg-2", title: "Second Message")
        
        mockMessageRepository.messagesById["msg-1"] = message1
        mockMessageRepository.messagesById["msg-2"] = message2
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.messages.count == 2)
        #expect(mockMessageRepository.getMessagesForUserCallCount == 1)
        #expect(mockMessageRepository.getMessagesForUserCalledWith[0] == userId)
    }
    
    @Test("Get messages returns empty for user with no messages")
    func getMessagesReturnsEmptyForNoMessages() async throws {
        // Given - no messages in repository
        let userId = "user-1"
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.messages.isEmpty)
        #expect(response.unreadCount == 0)
    }
    
    @Test("Get messages calculates correct unread count")
    func getMessagesCalculatesCorrectUnreadCount() async throws {
        // Given
        let userId = "user-1"
        let readMessage = createMessage(id: "msg-1", isRead: true)
        let unreadMessage1 = createMessage(id: "msg-2", isRead: false)
        let unreadMessage2 = createMessage(id: "msg-3", isRead: false)
        
        mockMessageRepository.messagesById["msg-1"] = readMessage
        mockMessageRepository.messagesById["msg-2"] = unreadMessage1
        mockMessageRepository.messagesById["msg-3"] = unreadMessage2
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.messages.count == 3)
        #expect(response.unreadCount == 2)
    }
    
    @Test("Get messages with all read returns zero unread count")
    func getMessagesWithAllReadReturnsZeroUnread() async throws {
        // Given
        let userId = "user-1"
        let readMessage1 = createMessage(id: "msg-1", isRead: true)
        let readMessage2 = createMessage(id: "msg-2", isRead: true)
        
        mockMessageRepository.messagesById["msg-1"] = readMessage1
        mockMessageRepository.messagesById["msg-2"] = readMessage2
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.messages.count == 2)
        #expect(response.unreadCount == 0)
    }
    
    @Test("Get messages with all unread returns correct count")
    func getMessagesWithAllUnreadReturnsCorrectCount() async throws {
        // Given
        let userId = "user-1"
        let unreadMessage1 = createMessage(id: "msg-1", isRead: false)
        let unreadMessage2 = createMessage(id: "msg-2", isRead: false)
        let unreadMessage3 = createMessage(id: "msg-3", isRead: false)
        
        mockMessageRepository.messagesById["msg-1"] = unreadMessage1
        mockMessageRepository.messagesById["msg-2"] = unreadMessage2
        mockMessageRepository.messagesById["msg-3"] = unreadMessage3
        
        // When
        let response = try await useCase.execute(userId: userId)
        
        // Then
        #expect(response.messages.count == 3)
        #expect(response.unreadCount == 3)
    }
    
    // MARK: - Error Tests
    
    @Test("Get messages propagates repository error")
    func getMessagesPropagatesRepositoryError() async throws {
        // Given
        mockMessageRepository.getMessagesForUserResult = .failure(DomainError.networkError)
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(userId: "user-1")
        }
    }
}
