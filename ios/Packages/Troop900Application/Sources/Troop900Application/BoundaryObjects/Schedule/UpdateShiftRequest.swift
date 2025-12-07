import Foundation
import Troop900Domain

public struct UpdateShiftRequest: Sendable, Equatable {
    public let shiftId: String
    public let date: Date?
    public let startTime: Date?
    public let endTime: Date?
    public let requiredScouts: Int?
    public let requiredParents: Int?
    public let location: String?
    public let label: String?
    public let notes: String?
    
    public init(
        shiftId: String,
        date: Date? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        requiredScouts: Int? = nil,
        requiredParents: Int? = nil,
        location: String? = nil,
        label: String? = nil,
        notes: String? = nil
    ) {
        self.shiftId = shiftId
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.requiredScouts = requiredScouts
        self.requiredParents = requiredParents
        self.location = location
        self.label = label
        self.notes = notes
    }
}
