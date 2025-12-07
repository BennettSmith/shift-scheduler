import Foundation
import Troop900Domain

public struct CreateShiftRequest: Sendable, Equatable {
    public let date: Date
    public let startTime: Date
    public let endTime: Date
    public let requiredScouts: Int
    public let requiredParents: Int
    public let location: String
    public let label: String?
    public let notes: String?
    public let seasonId: String?
    public let publishImmediately: Bool
    public let sendNotification: Bool
    
    public init(
        date: Date,
        startTime: Date,
        endTime: Date,
        requiredScouts: Int,
        requiredParents: Int,
        location: String,
        label: String? = nil,
        notes: String? = nil,
        seasonId: String? = nil,
        publishImmediately: Bool = true,
        sendNotification: Bool = true
    ) {
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
        self.seasonId = seasonId
        self.publishImmediately = publishImmediately
        self.sendNotification = sendNotification
    }
}
