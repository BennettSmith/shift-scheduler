import Foundation
import Troop900Domain

/// Request to get a week's schedule.
public struct WeekScheduleRequest: Sendable, Equatable {
    public let referenceDate: Date
    
    public init(referenceDate: Date) {
        self.referenceDate = referenceDate
    }
}
