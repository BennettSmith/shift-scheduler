import Foundation
import Troop900Domain

/// Request to send a message.
public struct SendMessageRequest: Sendable, Equatable {
    public let title: String
    public let body: String
    public let targetAudience: TargetAudience
    public let targetUserIds: [String]?
    public let targetHouseholdIds: [String]?
    public let priority: MessagePriority
    
    public init(
        title: String,
        body: String,
        targetAudience: TargetAudience,
        targetUserIds: [String]?,
        targetHouseholdIds: [String]?,
        priority: MessagePriority
    ) {
        self.title = title
        self.body = body
        self.targetAudience = targetAudience
        self.targetUserIds = targetUserIds
        self.targetHouseholdIds = targetHouseholdIds
        self.priority = priority
    }
}
