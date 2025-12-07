import Foundation

public struct CreateShiftResponse: Sendable, Equatable {
    public let shiftId: String
    public let status: ShiftStatus
    public let notificationSent: Bool
    
    public init(
        shiftId: String,
        status: ShiftStatus,
        notificationSent: Bool
    ) {
        self.shiftId = shiftId
        self.status = status
        self.notificationSent = notificationSent
    }
}
