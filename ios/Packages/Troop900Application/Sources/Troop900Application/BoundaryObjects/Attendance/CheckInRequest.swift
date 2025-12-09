import Foundation

/// Request to check in to a shift.
public struct CheckInRequest: Sendable, Equatable {
    public let assignmentId: String
    public let shiftId: String
    public let qrCodeData: String?
    public let location: Coordinate?
    
    public init(assignmentId: String, shiftId: String, qrCodeData: String?, location: Coordinate?) {
        self.assignmentId = assignmentId
        self.shiftId = shiftId
        self.qrCodeData = qrCodeData
        self.location = location
    }
}
