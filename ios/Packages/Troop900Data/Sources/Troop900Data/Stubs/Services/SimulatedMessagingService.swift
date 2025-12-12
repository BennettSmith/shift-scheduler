import Foundation
import Troop900Domain

/// Simulated implementation of MessagingService for testing and local development.
/// This simulates Cloud Functions behavior using in-memory data.
public final class SimulatedMessagingService: MessagingService, @unchecked Sendable {
    private let messageRepository: MessageRepository
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    private let lock = AsyncLock()
    
    public init(
        messageRepository: MessageRepository,
        userRepository: UserRepository,
        householdRepository: HouseholdRepository
    ) {
        self.messageRepository = messageRepository
        self.userRepository = userRepository
        self.householdRepository = householdRepository
    }
    
    public func sendMessage(
        title: String,
        body: String,
        targetAudience: TargetAudience,
        targetUserIds: [String]?,
        targetHouseholdIds: [String]?,
        priority: MessagePriority
    ) async throws -> String {
        // Determine target user IDs based on audience
        var userIds: [String] = []
        
        if let targetUserIds = targetUserIds {
            userIds = targetUserIds
        } else if let targetHouseholdIds = targetHouseholdIds {
            for householdId in targetHouseholdIds {
                let household = try await householdRepository.getHousehold(id: householdId)
                userIds.append(contentsOf: household.members)
            }
        } else {
            // Handle targetAudience
            switch targetAudience {
            case .all:
                // Would need to get all users - simplified for stub
                userIds = []
            case .scouts:
                // Would filter by role - simplified
                userIds = []
            case .parents:
                // Would filter by role - simplified
                userIds = []
            case .leadership:
                // Would filter by role - simplified
                userIds = []
            case .household:
                // Already handled above
                break
            case .individual:
                // Already handled above
                break
            }
        }
        
        // Create message
        let messageId = UUID().uuidString
        let message = Message(
            id: messageId,
            title: title,
            body: body,
            targetAudience: targetAudience,
            targetUserIds: userIds.isEmpty ? nil : userIds,
            targetHouseholdIds: targetHouseholdIds,
            senderId: "system", // Would be current user in real implementation
            sentAt: Date(),
            priority: priority,
            isRead: false
        )
        
        try await messageRepository.createMessage(message)
        
        return messageId
    }
    
    public func sendShiftReminder(shiftId: String) async throws {
        // Simplified - would get shift assignments and send messages
        // For stub, just create a generic reminder message
        let messageId = UUID().uuidString
        let message = Message(
            id: messageId,
            title: "Shift Reminder",
            body: "You have a shift coming up. Shift ID: \(shiftId)",
            targetAudience: .individual,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            senderId: "system",
            sentAt: Date(),
            priority: .normal,
            isRead: false
        )
        
        try await messageRepository.createMessage(message)
    }
    
    public func sendShiftCancellation(shiftId: String, reason: String?) async throws {
        // Simplified - would get shift assignments and send messages
        let messageId = UUID().uuidString
        let body = reason.map { "Shift cancelled. Reason: \($0)" } ?? "Shift has been cancelled"
        let message = Message(
            id: messageId,
            title: "Shift Cancelled",
            body: body,
            targetAudience: .individual,
            targetUserIds: nil,
            targetHouseholdIds: nil,
            senderId: "system",
            sentAt: Date(),
            priority: .high,
            isRead: false
        )
        
        try await messageRepository.createMessage(message)
    }
}
