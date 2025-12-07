import Foundation
import Troop900Domain

/// Protocol for sending a message.
public protocol SendMessageUseCaseProtocol: Sendable {
    func execute(request: SendMessageRequest) async throws -> String
}

/// Use case for sending a message to users.
public final class SendMessageUseCase: SendMessageUseCaseProtocol, Sendable {
    private let messagingService: MessagingService
    
    public init(messagingService: MessagingService) {
        self.messagingService = messagingService
    }
    
    public func execute(request: SendMessageRequest) async throws -> String {
        // Validate message content
        guard !request.title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            throw DomainError.invalidInput("Message title cannot be empty")
        }
        
        guard !request.body.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            throw DomainError.invalidInput("Message body cannot be empty")
        }
        
        // Validate audience
        switch request.targetAudience {
        case .individual:
            guard let userIds = request.targetUserIds, !userIds.isEmpty else {
                throw DomainError.invalidMessageRecipients
            }
        case .household:
            guard let householdIds = request.targetHouseholdIds, !householdIds.isEmpty else {
                throw DomainError.invalidMessageRecipients
            }
        default:
            break
        }
        
        // Call service to send message
        return try await messagingService.sendMessage(
            title: request.title,
            body: request.body,
            targetAudience: request.targetAudience,
            targetUserIds: request.targetUserIds,
            targetHouseholdIds: request.targetHouseholdIds,
            priority: request.priority
        )
    }
}
