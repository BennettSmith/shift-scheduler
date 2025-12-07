import Foundation
import Troop900Domain

public struct GenerateSeasonScheduleResponse: Sendable, Equatable {
    public let seasonId: String
    public let totalShiftsCreated: Int
    public let totalVolunteerSlots: Int
    public let datesWithShifts: Int
    public let specialEventCount: Int
    
    public init(
        seasonId: String,
        totalShiftsCreated: Int,
        totalVolunteerSlots: Int,
        datesWithShifts: Int,
        specialEventCount: Int
    ) {
        self.seasonId = seasonId
        self.totalShiftsCreated = totalShiftsCreated
        self.totalVolunteerSlots = totalVolunteerSlots
        self.datesWithShifts = datesWithShifts
        self.specialEventCount = specialEventCount
    }
}
