import Foundation
import Troop900Domain

public struct PublishScheduleResponse: Sendable, Equatable {
    public let seasonId: String
    public let shiftsPublished: Int
    public let notificationSent: Bool
    public let recipientCount: Int
    
    public init(
        seasonId: String,
        shiftsPublished: Int,
        notificationSent: Bool,
        recipientCount: Int
    ) {
        self.seasonId = seasonId
        self.shiftsPublished = shiftsPublished
        self.notificationSent = notificationSent
        self.recipientCount = recipientCount
    }
}
