import Foundation
import Troop900Domain

public struct PublishScheduleRequest: Sendable, Equatable {
    public let seasonId: String
    public let sendNotification: Bool
    public let notificationTitle: String?
    public let notificationMessage: String?
    public let highlightSpecialEvents: Bool
    
    public init(
        seasonId: String,
        sendNotification: Bool = true,
        notificationTitle: String? = nil,
        notificationMessage: String? = nil,
        highlightSpecialEvents: Bool = true
    ) {
        self.seasonId = seasonId
        self.sendNotification = sendNotification
        self.notificationTitle = notificationTitle
        self.notificationMessage = notificationMessage
        self.highlightSpecialEvents = highlightSpecialEvents
    }
}
