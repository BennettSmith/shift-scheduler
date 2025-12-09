import Foundation
import Troop900Domain

// MARK: - TargetAudienceType Mapping

extension TargetAudienceType {
    init(from domain: TargetAudience) {
        switch domain {
        case .all:
            self = .all
        case .scouts:
            self = .scouts
        case .parents:
            self = .parents
        case .leadership:
            self = .leadership
        case .household:
            self = .household
        case .individual:
            self = .individual
        }
    }
    
    func toDomain() -> TargetAudience {
        switch self {
        case .all:
            return .all
        case .scouts:
            return .scouts
        case .parents:
            return .parents
        case .leadership:
            return .leadership
        case .household:
            return .household
        case .individual:
            return .individual
        }
    }
}

// MARK: - MessagePriorityType Mapping

extension MessagePriorityType {
    init(from domain: MessagePriority) {
        switch domain {
        case .low:
            self = .low
        case .normal:
            self = .normal
        case .high:
            self = .high
        case .urgent:
            self = .urgent
        }
    }
    
    func toDomain() -> MessagePriority {
        switch self {
        case .low:
            return .low
        case .normal:
            return .normal
        case .high:
            return .high
        case .urgent:
            return .urgent
        }
    }
}

// MARK: - MessageInfo Mapping

extension MessageInfo {
    init(from message: Message) {
        self.init(
            id: message.id,
            title: message.title,
            body: message.body,
            priority: MessagePriorityType(from: message.priority),
            sentAt: message.sentAt,
            isRead: message.isRead
        )
    }
}
