import Foundation

public struct CreateShiftResponse: Sendable, Equatable {
    public let shiftId: String
    public let status: ShiftStatusType
    public let notificationSent: Bool
    
    public init(
        shiftId: String,
        status: ShiftStatusType,
        notificationSent: Bool
    ) {
        self.shiftId = shiftId
        self.status = status
        self.notificationSent = notificationSent
    }
}
