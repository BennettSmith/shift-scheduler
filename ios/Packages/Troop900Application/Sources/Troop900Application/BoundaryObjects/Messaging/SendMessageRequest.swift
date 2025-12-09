import Foundation

/// Request to send a message.
public struct SendMessageRequest: Sendable, Equatable {
    public let title: String
    public let body: String
    public let targetAudience: TargetAudienceType
    public let targetUserIds: [String]?
    public let targetHouseholdIds: [String]?
    public let priority: MessagePriorityType
    
    public init(
        title: String,
        body: String,
        targetAudience: TargetAudienceType,
        targetUserIds: [String]?,
        targetHouseholdIds: [String]?,
        priority: MessagePriorityType
    ) {
        self.title = title
        self.body = body
        self.targetAudience = targetAudience
        self.targetUserIds = targetUserIds
        self.targetHouseholdIds = targetHouseholdIds
        self.priority = priority
    }
}
