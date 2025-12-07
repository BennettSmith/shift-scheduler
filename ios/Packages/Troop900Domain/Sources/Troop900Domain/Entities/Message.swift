import Foundation

/// Represents a message sent to users.
public struct Message: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let title: String
    public let body: String
    public let targetAudience: TargetAudience
    public let targetUserIds: [String]?
    public let targetHouseholdIds: [String]?
    public let senderId: String
    public let sentAt: Date
    public let priority: MessagePriority
    public let isRead: Bool
    
    public init(
        id: String,
        title: String,
        body: String,
        targetAudience: TargetAudience,
        targetUserIds: [String]?,
        targetHouseholdIds: [String]?,
        senderId: String,
        sentAt: Date,
        priority: MessagePriority,
        isRead: Bool
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.targetAudience = targetAudience
        self.targetUserIds = targetUserIds
        self.targetHouseholdIds = targetHouseholdIds
        self.senderId = senderId
        self.sentAt = sentAt
        self.priority = priority
        self.isRead = isRead
    }
}

/// Represents the priority of a message.
public enum MessagePriority: String, Sendable, Codable {
    case low
    case normal
    case high
    case urgent
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
}
