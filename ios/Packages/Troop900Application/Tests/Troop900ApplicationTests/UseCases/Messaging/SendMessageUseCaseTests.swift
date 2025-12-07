import Testing
import Foundation
@testable import Troop900Application
@testable import Troop900Domain

@Suite("SendMessageUseCase Tests")
struct SendMessageUseCaseTests {
    
    // MARK: - Test Dependencies
    
    private let mockMessagingService = MockMessagingService()
    
    private var useCase: SendMessageUseCase {
        SendMessageUseCase(messagingService: mockMessagingService)
    }
    
    // MARK: - Success Tests
    
    @Test("Send message to all users succeeds")
    func sendMessageToAllSucceeds() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Important Announcement",
            body: "This is the message body.",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When
        let messageId = try await useCase.execute(request: request)
        
        // Then
        #expect(messageId.isEmpty == false)
        #expect(mockMessagingService.sendMessageCallCount == 1)
        #expect(mockMessagingService.sendMessageCalledWith[0].title == "Important Announcement")
        #expect(mockMessagingService.sendMessageCalledWith[0].body == "This is the message body.")
        #expect(mockMessagingService.sendMessageCalledWith[0].targetAudience == .all)
        #expect(mockMessagingService.sendMessageCalledWith[0].priority == .normal)
    }
    
    @Test("Send message to individual users succeeds")
    func sendMessageToIndividualsSucceeds() async throws {
        // Given
        let targetUsers = ["user-1", "user-2", "user-3"]
        let request = SendMessageRequest(
            title: "Personal Message",
            body: "This is for you specifically.",
            targetAudience: .individual,
            targetUserIds: targetUsers,
            targetHouseholdIds: nil,
            priority: .high
        )
        
        // When
        let messageId = try await useCase.execute(request: request)
        
        // Then
        #expect(messageId.isEmpty == false)
        #expect(mockMessagingService.sendMessageCalledWith[0].targetAudience == .individual)
        #expect(mockMessagingService.sendMessageCalledWith[0].targetUserIds == targetUsers)
    }
    
    @Test("Send message to household succeeds")
    func sendMessageToHouseholdSucceeds() async throws {
        // Given
        let targetHouseholds = ["household-1"]
        let request = SendMessageRequest(
            title: "Household Update",
            body: "Message for your household.",
            targetAudience: .household,
            targetUserIds: nil,
            targetHouseholdIds: targetHouseholds,
            priority: .normal
        )
        
        // When
        let messageId = try await useCase.execute(request: request)
        
        // Then
        #expect(messageId.isEmpty == false)
        #expect(mockMessagingService.sendMessageCalledWith[0].targetAudience == .household)
        #expect(mockMessagingService.sendMessageCalledWith[0].targetHouseholdIds == targetHouseholds)
    }
    
    @Test("Send urgent message succeeds")
    func sendUrgentMessageSucceeds() async throws {
        // Given
        let request = SendMessageRequest(
            title: "URGENT: Important Notice",
            body: "Please read immediately.",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .urgent
        )
        
        // When
        let messageId = try await useCase.execute(request: request)
        
        // Then
        #expect(messageId.isEmpty == false)
        #expect(mockMessagingService.sendMessageCalledWith[0].priority == .urgent)
    }
    
    // MARK: - Validation Tests
    
    @Test("Send message fails with empty title")
    func sendMessageFailsWithEmptyTitle() async throws {
        // Given
        let request = SendMessageRequest(
            title: "",
            body: "Some body content",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send message fails with whitespace-only title")
    func sendMessageFailsWithWhitespaceTitle() async throws {
        // Given
        let request = SendMessageRequest(
            title: "   \n\t  ",
            body: "Some body content",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send message fails with empty body")
    func sendMessageFailsWithEmptyBody() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send message fails with whitespace-only body")
    func sendMessageFailsWithWhitespaceBody() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "   \n\t  ",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send individual message fails without user IDs")
    func sendIndividualMessageFailsWithoutUserIds() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "Valid body",
            targetAudience: .individual,
            targetUserIds: nil, // Missing required user IDs
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send individual message fails with empty user IDs")
    func sendIndividualMessageFailsWithEmptyUserIds() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "Valid body",
            targetAudience: .individual,
            targetUserIds: [], // Empty user IDs
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send household message fails without household IDs")
    func sendHouseholdMessageFailsWithoutHouseholdIds() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "Valid body",
            targetAudience: .household,
            targetUserIds: nil,
            targetHouseholdIds: nil, // Missing required household IDs
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    @Test("Send household message fails with empty household IDs")
    func sendHouseholdMessageFailsWithEmptyHouseholdIds() async throws {
        // Given
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "Valid body",
            targetAudience: .household,
            targetUserIds: nil,
            targetHouseholdIds: [], // Empty household IDs
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 0)
    }
    
    // MARK: - Error Tests
    
    @Test("Send message propagates service error")
    func sendMessagePropagatesServiceError() async throws {
        // Given
        mockMessagingService.sendMessageResult = .failure(DomainError.networkError)
        
        let request = SendMessageRequest(
            title: "Valid Title",
            body: "Valid body",
            targetAudience: .all,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            priority: .normal
        )
        
        // When/Then
        await #expect(throws: DomainError.self) {
            try await useCase.execute(request: request)
        }
        #expect(mockMessagingService.sendMessageCallCount == 1)
    }
}
