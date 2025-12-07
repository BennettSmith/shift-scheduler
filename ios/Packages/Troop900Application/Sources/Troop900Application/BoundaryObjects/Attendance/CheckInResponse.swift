import Foundation
import Troop900Domain

/// Response after checking in to a shift.
public struct CheckInResponse: Sendable, Equatable {
    public let success: Bool
    public let attendanceRecordId: String
    public let checkInTime: Date
    public let message: String
    
    public init(success: Bool, attendanceRecordId: String, checkInTime: Date, message: String) {
        self.success = success
        self.attendanceRecordId = attendanceRecordId
        self.checkInTime = checkInTime
        self.message = message
    }
}
